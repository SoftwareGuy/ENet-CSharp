# ENet-CSharp Quickstart Examples

## A server code example:

```c#
using (Host server = new Host()) {
	Address address = new Address();

	address.Port = port;
	server.Create(address, maxClients);

	Event netEvent;

	while (!Console.KeyAvailable) {
		bool polled = false;

		while (!polled) {
			if (server.CheckEvents(out netEvent) <= 0) {
				if (server.Service(15, out netEvent) <= 0)
					break;

				polled = true;
			}

			switch (netEvent.Type) {
				case EventType.None:
					break;

				case EventType.Connect:
					Console.WriteLine($"Client connected - ID: {netEvent.Peer.ID}, IP: {netEvent.Peer.IP}");
					break;

				case EventType.Disconnect:
					Console.WriteLine($"Client disconnected - ID: {netEvent.Peer.ID}, IP: {netEvent.Peer.IP}");
					break;

				case EventType.Timeout:
					Console.WriteLine($"Client timeout - ID: {netEvent.Peer.ID}, IP: {netEvent.Peer.IP}");
					break;

				case EventType.Receive:
					Console.WriteLine($"Packet received from peer ID: {netEvent.Peer.ID}, IP: {netEvent.Peer.IP}, Channel ID: {netEvent.ChannelID}, Data length: {netEvent.Packet.Length}");
					netEvent.Packet.Dispose();
					break;
			}
		}
	}

	server.Flush();
}
```

## A client code sample:

```c#
using (Host client = new Host()) {
	Address address = new Address();

	address.SetHost(ip);
	address.Port = port;
	client.Create();

	Peer peer = client.Connect(address);

	Event netEvent;

	while (!Console.KeyAvailable) {
		bool polled = false;

		while (!polled) {
			if (client.CheckEvents(out netEvent) <= 0) {
				if (client.Service(15, out netEvent) <= 0)
					break;

				polled = true;
			}

			switch (netEvent.Type) {
				case EventType.None:
					break;

				case EventType.Connect:
					Console.WriteLine("Client connected to server");
					break;

				case EventType.Disconnect:
					Console.WriteLine("Client disconnected from server");
					break;

				case EventType.Timeout:
					Console.WriteLine("Client connection timeout");
					break;

				case EventType.Receive:
					Console.WriteLine($"Packet received from server - Channel ID: {netEvent.ChannelID}, Data length: {netEvent.Packet.Length}");
					netEvent.Packet.Dispose();
					break;
			}
		}
	}

	client.Flush();
}
```

## Create and send a new packet:
```csharp
Packet packet = default(Packet);
byte[] data = new byte[64];

packet.Create(data);
peer.Send(channelID, ref packet);
```

## Copy payload from a packet:
```csharp
byte[] buffer = new byte[1024];

netEvent.Packet.CopyTo(buffer);
```

## (Pro-tier) Using a custom memory allocator:
```csharp
AllocCallback OnMemoryAllocate = (size) => {
	return Marshal.AllocHGlobal(size);
};

FreeCallback OnMemoryFree = (memory) => {
	Marshal.FreeHGlobal(memory);
};

NoMemoryCallback OnNoMemory = () => {
	throw new OutOfMemoryException();
};

Callbacks callbacks = new Callbacks(OnMemoryAllocate, OnMemoryFree, OnNoMemory);

if (ENet.Library.Initialize(callbacks))
	Console.WriteLine("ENet successfully initialized using a custom memory allocator");
```
