<p align="center"> 
  <img src="https://i.imgur.com/CxkUxTs.png" alt="alt logo">
</p>

[![Ko-Fi](https://img.shields.io/badge/Donate-Ko--Fi-red)](https://ko-fi.com/coburn) 
[![PayPal](https://img.shields.io/badge/Donate-PayPal-blue)](https://paypal.me/coburn64)
![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)
_**Please consider a donation (see the Ko-Fi button above) if this project is useful to you.**_


This is a improved/refactored version of ENet-CSharp. Due to unfortunate circumstances between two development entities, the upstream repository was archived and is only updated when patches are applied (all development work is done in private). Since you cannot interact with archived repositories outside of code-related things, this repository acts as a workaround to those issues.

Unlike the upstream repository code of conduct where issue tickets were closed randomly for no reason, if you have a problem with ENet-CSharp, we'll be able to investigate. We also have a proper implementation of the `ENET_DEBUG` definition, allowing logging output to be written to `enet_log.txt` for further diagnosis and troubleshooting. Code cleanups and optimizations for better performance are included, and if someone files a supposedly-a-bug tickets actually get analyzed and if it's really a bug, it'll get fixed.

### Compatibility with Upstream
Don't use the upstream releases with the code in this repository. You will most likely get crashes or weird things happening.

### Building
You can use the IDE of Visual Studio to build if you like. The following will be oriented for power users and command line heroes.

Unlike upstream, this repo has a complete build system that harnesses the power of `MSBuild`. 

- Ensure you have dotnet 2.2 SDK at least installed. You can use 2.1 since it's LTS but ehh...
- **If you are building on Windows:** Make sure you have Visual Studio 2017/2019 installed, C++ Support, Windows 10 SDK and CMake. CMake sometimes doesn't get automatically installed with Visual Studio, so you may need to grab it manually.
- **If you are building on Mac:** Make sure you have Xcode CLI Tools installed (XCode might also be required).
- Clone a fresh copy of this Git Repo somewhere on your workstation's filesystem.
- **If you are building on Linux:** Make sure you have your repositories' `build-essential` and `cmake` package installed. On Debian and Ubuntu-based distros, you can do `sudo apt -y build-essential cmake` to install the required things.
- **If you are building for iOS or Android:** Hold up. We haven't implemented that yet... You'll have to proceed on foot since they use toolchains.
- Open a command prompt/terminal and change directory into the newly cloned git repository.
- Run `dotnet build`.

**Protip:** You can append `-c Release` or `-c Debug` to your `dotnet build` command to build a release binary or a debug binary of ENET's C library.

You will see an anime babe appear followed by [Ignorance](https://github.com/SoftwareGuy/Ignorance) ASCII art. 

CMake will fire up, configure itself after inspecting your build environment and hopefully spit out a binary blob inside a `Unity/Plugins` directory. On Windows, this will be a DLL, on Mac it will be a `.bundle` file and on Linux it will be a shared object (`.so`). This can be used with Unity or another thing like a C# NET Core application or even other C/C++ apps. 

#### Testing
- `dotnet test` will run some sanity checks and make sure ENET initializes, data is received and sent correctly, etc.

#### Rebuilding
Inside the directory that you cloned the repo to, run:
- `dotnet clean`
- `dotnet build`

It is recommended to clean the repository work space before building.

### Features
- Lightweight and straightforward
- Low resource consumption
- Dual-stack IPv4/IPv6 support
- Connection management, Sequencing, Channels, Reliability, Fragmentation, Reassembly
- Aggregation
- Adaptability and portability

### Usage
- Initialize ENET first before doing anything by calling the `ENet.Library.Initialize();` function. It will return false on failure, return true on success. You can use this to gracefully quit your application should it fail to initialize, for example.
- Once you are done, deinitialize the library using `ENet.Library.Deinitialize();` function.

### Code Examples/Quick Start
A good idea is to check out the [common mistakes during integration](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/COMMON-MISTAKES.md) documentation.

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
					Console.WriteLine($"Packet received from server - Channel ID: {netEvent.ChannelID}, Data length: {netEvent.Packet.Length}");
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
The best-known strategy is to use ENet in an independent I/O thread. This can be achieved by using Threads and enqueuing packets to be sent and received back and forth via ConcurrentQueues (this is what [Ignorance](https://github.com/SoftwareGuy/Ignorance) uses). In fact, some internal testing showed that ENet had very impressive performance using a thread and ConcurrentQueues approach to network I/O, even faster than RingBuffers/Disruptors. Use whatever queue system you feel comfortable with, just make sure you empty the queues as fast as possible in your applications.

Threading in Unity was problematic but later versions (2018.3+) have proven to be fine. 
Please beware that using Threads inside a Unity environment can be problematic and can lead to the Unity Editor or built games randomly crashing without any warning. Use them with caution!

### Functionality
In general, ENet is not thread-safe, but some of its functions can be used safely if the user is careful enough:

`Packet` structure and its functions are safe until a packet is only moving across threads by value and a custom memory allocator is not used.

`Peer.ID` as soon as a pointer to a peer was obtained from the native side, the ID will be cached in `Peer` structure for further actions with objects that assigned to that ID. `Peer` structure can be moved across threads by value, but its functions are not thread-safe because data in memory may change by the servicing functions in another thread.

`Library.Time` utilizes atomic primitives internally for managing local monotonic time.

API Documentation
--------
See `DOCUMENTATION.md` [here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/DOCUMENTATION.md).

Credits
-------
- Coburn
- c6burns
- Katori
- Mirror Team & Discord Members

Some thanks to:
- FSE (actually a helpful person when he's in a good mood)
- NX (well, he had the original ENet-CSharp repo I manually forked)

Psst... If you want to know what started this repository, go [read my blog 
post](https://www.coburnsdomain.com/2019/03/getting-blocked-from-an-upstream-github-repo-nx-edition) as it'll detail the whole show. It's a good read.
