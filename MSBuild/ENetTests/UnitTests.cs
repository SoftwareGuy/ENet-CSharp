/*
 * Copyright (c) 2019 Chris Burns <chris@kitty.city>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
using NUnit.Framework;
using System;
using System.Net;
using System.Collections.Generic;
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
    public void MallocAndFree()
    {
        Stack<IntPtr> allocs = new Stack<IntPtr>();
        for (int i = 0; i < 1024; i++)
        {
            IntPtr alloc = ENet.Library.Malloc(1024);
            Assert.NotNull(alloc);
            allocs.Push(alloc);
        }

        while (allocs.Count > 0)
        {
            ENet.Library.Free(allocs.Pop());
        }
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
        const ushort port = 7777;
        const int maxClients = 1;
        const byte dataVal = 42;

        int clientEvents = 0;
        int clientConnected = 0;
        int clientDisconnected = 0;
        int clientTimeout = 0;
        int clientNone = 0;
        int clientRecvData = 0;
        int serverEvents = 0;
        int serverConnected = 0;
        int serverDisconnected = 0;
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

            address.SetIP("127.0.0.1");
            client.Create();

            Peer clientPeer = default;
            Stopwatch sw = Stopwatch.StartNew();
            while (clientState != ClientState.Disconnected && sw.ElapsedMilliseconds < 10000)
            {
                while (server.Service(15, out Event netEvent) > 0)
                {
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
                            clientState = ClientState.Disconnected;
                            break;
                        case EventType.Timeout:
                            serverTimeout++;
                            break;
                        case EventType.Receive:
                            serverRecvData++;
                            Packet packet = default(Packet);
                            byte[] data = new byte[64];
                            netEvent.Packet.CopyTo(data);

                            for (int i = 0; i < data.Length; i++) Assert.True(data[i] == dataVal);

                            packet.Create(data);
                            netEvent.Peer.Send(0, ref packet);
                            netEvent.Packet.Dispose();
                            break;
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
                            clientState = ClientState.Connected;
                            break;
                        case EventType.Disconnect:
                            clientDisconnected++;
                            clientState = ClientState.Disconnected;
                            break;
                        case EventType.Timeout:
                            clientTimeout++;
                            break;
                        case EventType.Receive:
                            clientRecvData++;
                            byte[] data = new byte[64];
                            Packet packet = netEvent.Packet;
                            packet.CopyTo(data);
                            for (int i = 0; i < data.Length; i++) Assert.True(data[i] == dataVal);
                            netEvent.Packet.Dispose();

                            clientState = ClientState.RecvData;
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
                    Packet packet = default(Packet);
                    byte[] data = new byte[64];
                    for (int i = 0; i < data.Length; i++) data[i] = dataVal;

                    packet.Create(data);
                    clientPeer.Send(0, ref packet);

                    clientState = ClientState.SendData;
                }
                else if (clientState == ClientState.RecvData)
                {
                    clientPeer.DisconnectNow(0);
                    clientState = ClientState.Disconnecting;
                }
            }
        }

        Assert.True(clientEvents != 0, "client host never generated an event");
        Assert.True(serverEvents != 0, "server host never generated an event");

        Assert.True(clientState == ClientState.Disconnected, "client didn't fully disconnect");

        Assert.AreEqual(1, clientConnected, "client should have connected once");
        Assert.AreEqual(1, serverConnected, "server should have had one inbound connect");

        Assert.AreEqual(1, clientRecvData, "client should have recvd once");
        Assert.AreEqual(1, serverRecvData, "server should have recvd once");

        Assert.AreEqual(0, clientTimeout, "client had timeout events");
        Assert.AreEqual(0, serverTimeout, "server had timeout events");

        Assert.AreEqual(0, clientNone, "client had none events");
        Assert.AreEqual(0, serverNone, "server had none events");

        Assert.AreEqual(1, serverDisconnected, "server should have had one client disconnect");
    }
}
