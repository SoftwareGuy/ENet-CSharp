using NUnit.Framework;
using System;
using System.Net;
using System.Diagnostics;
using ENet;

public class UnitTests
{
    enum ClientState
    {
        None,
        Connecting,
        Connected,
        SendData,
        RecvData,
        Disconnecting,
        Disconnected,
    }

    [OneTimeSetUp]
    public void FixtureSetup()
    {
    }

    [OneTimeTearDown]
    public void FixtureCleanup()
    {
    }

    [SetUp]
    public void TestSetup()
    {
    }

    [TearDown]
    public void TestCleanup()
    {
    }

    [Test]
    public void InitAndUninit()
    {
        using (Host host = new Host())
        {
        }
    }

    [Test]
    public void SendAndRecv()
    {
        ushort port = 7777;
        int maxClients = 1;

        int clientEvents = 0;
        int clientConnected = 0;
        int clientDisconnected = 0;
        int clientTimeout = 0;
        int clientNone = 0;
        int clientSendData = 0;
        int clientRecvData = 0;
        int serverEvents = 0;
        int serverConnected = 0;
        int serverDisconnected = 0;
        int serverSendData = 0;
        int serverRecvData = 0;
        int serverTimeout = 0;
        int serverNone = 0;

        ClientState clientState = ClientState.None;

        using (Host client = new Host())
        using (Host server = new Host())
        {
            Address address = new Address();
            address.Port = port;
            server.Create(address, maxClients);

            address.SetHost("0.0.0.0");
            client.Create();

            Peer clientPeer;
            Stopwatch sw = Stopwatch.StartNew();
            while (sw.ElapsedMilliseconds < 10000)
            {
                while (server.Service(15, out Event netEvent) > 0) {
                    serverEvents++;
                    switch (netEvent.Type)
                    {
                        case EventType.None:
                            serverNone++;
                            break;
                        case EventType.Connect:
                            serverConnected++;
                            break;
                        case EventType.Disconnect:
                            serverDisconnected++;
                            break;
                        case EventType.Timeout:
                            serverTimeout++;
                            break;
                        case EventType.Receive:
                            serverRecvData++;
                            netEvent.Packet.Dispose();
                            break;
                    }
                }
            }
            server.Flush();

            while (client.Service(15, out Event netEvent) > 0)
            {
                clientEvents++;
                switch (netEvent.Type)
                {
                    case EventType.None:
                        clientNone++;
                        break;
                    case EventType.Connect:
                        clientConnected++;
                        break;
                    case EventType.Disconnect:
                        clientDisconnected++;
                        break;
                    case EventType.Timeout:
                        clientTimeout++;
                        break;
                    case EventType.Receive:
                        clientRecvData++;
                        netEvent.Packet.Dispose();
                        break;
                }
            }
            client.Flush();

            if (clientState == ClientState.None)
            {
                clientState = ClientState.Connecting;
                clientPeer = client.Connect(address);
            }
            else if (clientState == ClientState.Connected)
            {

            }
        }

        Assert.True(clientEvents != 0, "client host never generated an event");
        Assert.True(serverEvents != 0, "server host never generated an event");
        Assert.True(clientState != ClientState.None, "client never changed state");
        Assert.AreEqual(1, clientConnected, "client did not connect to server");
        Assert.AreEqual(1, serverConnected, "server did not see client connection");
    }
}
