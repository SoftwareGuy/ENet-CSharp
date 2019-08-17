<p align="center"> 
  <img src="https://i.imgur.com/CxkUxTs.png" alt="alt logo">
</p>

[![PayPal](https://drive.google.com/uc?id=1OQrtNBVJehNVxgPf6T6yX1wIysz1ElLR)](https://www.paypal.me/coburn64)

Welcome to a improved/refactored version of nxrighthere's ENET-CSharp repository. This repo started out as a clone of NX's repository but has since had some extras that the original repository did not. Some cherry picked commits are included from NX when deemed they are worthy of being blended into the repository.

Some features included in this repository include:

- Logging support for ENET Debug Mode
- Cleanups and Optimizations
- No auto-closing upon submitting a Issue Support Ticket!
- Supposedly-a-bug bugs actually get analyzed and if it's really a bug, it'll get fixed!
- And a bunch of other shit that makes it worthwhile using.

If you want to know what started this repository, go [read my blog 
post](https://www.coburnsdomain.com/2019/03/getting-blocked-from-an-upstream-github-repo-nx-edition) as it'll detail the whole show. It's a good read.

### Compatibility with Upstream
Don't even try using this version of ENET and ENET-CSharp with the upstream repository. It'll likely look at you strange and catch fire. Just don't.

### Features
- Lightweight and straightforward
- Low resource consumption
- Dual-stack IPv4/IPv6 support
- Connection management, Sequencing, Channels, Reliability, Fragmentation, Reassembly
- Compression
- Aggregation
- Adaptability and last but not least portability

Please, read [common mistakes](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/COMMON-MISTAKES.md) during integration. Issues filed here will be analyzed and fixed independently of upstream.

### Building
TODO: Come back and fill this in.

***Old shit left below as reference***

To build the native library appropriate software is required:

For desktop platforms [CMake](https://cmake.org/download/) with GNU Make or Visual Studio.

For mobile platforms [NDK](https://developer.android.com/ndk/downloads/) for Android and [Xcode](https://developer.apple.com/xcode/) for iOS. Make sure that all compiled libraries are assigned to appropriate platforms and CPU architectures.

To build the library for Nintendo Switch, follow [this](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/BUILD-FOR-SWITCH.txt) guide.

Define `ENET_LZ4` to build the library with support for an optional packet-level compression.

A managed assembly can be built using any available compiling platform that supports C# 3.0 or higher.

### Usage
- Initialize ENET first before doing anything by calling the `ENet.Library.Initialize();` function. It will return false on failure, return true on success. You can use this to gracefully quit your application should it fail to initialize, for example.
- Once you are done, deinitialize the library using `ENet.Library.Deinitialize();` function.

### .NET Code Examples/Quick Start
##### A server code example:
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
					Console.WriteLine("Client connected - ID: " + netEvent.Peer.ID + ", IP: " + netEvent.Peer.IP);
					break;

				case EventType.Disconnect:
					Console.WriteLine("Client disconnected - ID: " + netEvent.Peer.ID + ", IP: " + netEvent.Peer.IP);
					break;

				case EventType.Timeout:
					Console.WriteLine("Client timeout - ID: " + netEvent.Peer.ID + ", IP: " + netEvent.Peer.IP);
					break;

				case EventType.Receive:
					Console.WriteLine("Packet received from - ID: " + netEvent.Peer.ID + ", IP: " + netEvent.Peer.IP + ", Channel ID: " + netEvent.ChannelID + ", Data length: " + netEvent.Packet.Length);
					netEvent.Packet.Dispose();
					break;
			}
		}
	}

	server.Flush();
}
```

##### A client code sample:
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
					Console.WriteLine("Packet received from server - Channel ID: " + netEvent.ChannelID + ", Data length: " + netEvent.Packet.Length);
					netEvent.Packet.Dispose();
					break;
			}
		}
	}

	client.Flush();
}
```

##### Create and send a new packet:
```csharp
Packet packet = default(Packet);
byte[] data = new byte[64];

packet.Create(data);
peer.Send(channelID, ref packet);
```

##### Copy payload from a packet:
```csharp
byte[] buffer = new byte[1024];

netEvent.Packet.CopyTo(buffer);
```

##### (Pro-tier) Using a custom memory allocator:
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

### Unity
Usage is almost the same as in the .NET environment, except that the console functions must be replaced with functions provided by Unity. If the `Host.Service()` will be called in a game loop, then make sure that the timeout parameter set to 0 which means non-blocking. Also, make sure Unity runs in the background by enabling the ***Run in Background*** player setting.

Multi-threading
--------
### Strategy
The best-known strategy is to use ENet in an independent I/O thread. This can be achieved by using Threads and sending stuff to be sent and received back and forth via ConcurrentQueues. 

In fact, some internal testing showed that ENET had very impressive performance using a thread and queues approach to network I/O, even faster than RingBuffers and Disruptors. Please be beware that using Threads inside a Unity environment can be problematic and can lead to the Unity Editor or built games randomly crashing without any warning. Use it with caution.

### Functionality
In general, ENet is not thread-safe, but some of its functions can be used safely if the user is careful enough:

`Packet` structure and its functions are safe until a packet is only moving across threads by value and a custom memory allocator is not used.

`Peer.ID` as soon as a pointer to a peer was obtained from the native side, the ID will be cached in `Peer` structure for further actions with objects that assigned to that ID. `Peer` structure can be moved across threads by value, but its functions  are not thread-safe because data in memory may change by the service in another thread.

`Library.Time` utilizes atomic primitives internally for managing local monotonic time.

Documentation
--------
See `DOCUMENTATION.md` [here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/DOCUMENTATION.md).

Credits
-------
- c6burns
- SoftwareGuy (Coburn)
- The Mirror Development team
- The Mirror supporters on the Discord

Some thanks to:
- FSE
- NX

**Copy pasting code and slapping your name on it is bad, mmkay?**
