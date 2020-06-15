<p align="center"> 
  <img src="https://i.imgur.com/CxkUxTs.png" alt="alt logo">
</p>

[![Ko-Fi](https://img.shields.io/badge/Donate-Ko--Fi-red)](https://ko-fi.com/coburn) 
[![PayPal](https://img.shields.io/badge/Donate-PayPal-blue)](https://paypal.me/coburn64)
![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)
![Master Build](https://github.com/SoftwareGuy/ENet-CSharp/workflows/Master%20Build/badge.svg)

_**Please consider a donation (see the Ko-Fi button above) if this project is useful to you.**_

## What's this?
This is a improved/refactored version of ENet-CSharp, forked from another ENet fork. Due to unfortunate circumstances between two development entities, the upstream repository was archived and is only updated when patches are applied (all development work is done in private). Since you cannot interact with archived repositories outside of code-related things, this repository acts as a workaround to those issues.

In short, this is an independent ENet implementation with a modified protocol for C, C++, C#, and other languages. The original C library both forks are based on can be found [here](https://github.com/lsalzman/enet).

Unlike the upstream repository code of conduct where issue tickets were closed randomly for no reason, if you have a problem with ENet-CSharp, we'll be able to investigate. We also have a proper implementation of the `ENET_DEBUG` definition, allowing logging output to be written to `enet_log.txt` for further diagnosis and troubleshooting. Code cleanups and optimizations for better performance are included, and if someone files a supposedly-a-bug tickets actually get analyzed and if it's really a bug, it'll get fixed.

## Compatibility with Upstream
Don't use the upstream releases with the code in this repository. You will most likely get crashes or weird things happening.

## Building your own binaries
If you don't want to take the automatically built libraries in the releases section, you can use the Visual Studio MSBuild engine to build if you like. However the following will be oriented for power users and command line heroes, and requires NET Core SDK 2.2 to work correctly.

### Desktop Compile

- **Windows:** Make sure you have Visual Studio 2017/2019 installed with the C++ Support bundle ticked, a recent Windows 10 SDK and CMake. CMake sometimes doesn't get automatically installed with Visual Studio, so you may need to grab it manually from Kitware's website. Ensure it's a recent version (anything 3.16+ works).

- **MacOS:** Make sure you have Apple Xcode CLI Tools installed (Xcode might also be required for the MacOS SDK).

- **Linux:** Make sure you have your repositories' `build-essential` and `cmake` package installed. On Debian and Ubuntu-based distros, you can do `sudo apt -y build-essential cmake` to install the required things.

### Mobile 

- **Android:** Ensure you have the Android NDK installed. Easiest way to do this to go into `Sources/Native` and run when `ndk-build`. A fresh batch of ENET binaries should then be spat out, which can be used in your project.

- **Apple iOS:** Using **Terminal.app** on your MacOS device, navigate to the `Build-iOS` directory and run the command file found inside. You might need to make it executable, however. It will try to auto-pilot a build for you, just make sure you have CMake installed for MacOS and a recent Xcode installation. Library code signing will be disabled for the build.

### Console
- **Nintendo Switch:** A old guide is available [here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/BUILD-FOR-SWITCH.txt). However, it will require some modification to work with the Switch OS and Nintendo's own SDK. Since said SDK is under NDA, limited public info can be provided.

- **Playstation 4/Vita:** An Vita port exists already, however I am not planning to add support for the Vita to this repository. PS4 is obviously no go as well.

- **Other console not listed:** Open a issue ticket and I'll gladly add your steps for your platform here.

### Recipe for victory
- Clone a fresh copy of this Git Repo somewhere on your workstation's filesystem.
- Open a command prompt/terminal and change directory into the newly cloned git repository.
- Run `dotnet build`. 

**Protip:** You can append `-c Release` or `-c Debug` to your `dotnet build` command to build a release binary or a debug binary of ENET's C library. At the moment, the default build is a Debug build.

You will see an anime babe appear followed by [Ignorance](https://github.com/SoftwareGuy/Ignorance) ASCII art. Thanks to c6 for that eyecandy!

CMake will fire up, configure itself after inspecting your build environment and hopefully spit out a binary blob inside a `Unity/Plugins` directory. On Windows, this will be a DLL, on Mac it will be a `.bundle` file and on Linux it will be a shared object (`.so`). This can be used with Unity or other applications like a C# NET Core application or C/C++ app.

## Testing
- `dotnet test` will run some sanity checks and make sure ENET initializes, data is received and sent correctly, etc.

## Rebuilding
Inside the directory that you cloned the repo to, run:
- `dotnet clean`
- `dotnet build` (don't forget about the `-c Release/Debug` argument as mentioned earlier!)

It is recommended to clean the repository work space before building.

## Native Library Features
- Lightweight and straightforward
- Low resource consumption
- Dual-stack IPv4/IPv6 support
- Connection management, Sequencing, Channels, Reliability, Fragmentation, Reassembly
- Aggregation
- Adaptability and portability

## Usage
- Initialize ENET first before doing anything by calling the `ENet.Library.Initialize();` function. It will return false on failure, return true on success. You can use this to gracefully quit your application should it fail to initialize, for example.
- Once you are done, deinitialize the library using `ENet.Library.Deinitialize();` function.

### ENet-CSharp with Unity
Usage is almost the same as in the .NET environment, except that the console functions must be replaced with functions provided by Unity. If the `Host.Service()` will be called in a game loop, then make sure that the timeout parameter set to 0 which means non-blocking. Also make sure Unity runs in the background by enabling the ***Run in Background*** player setting.

### Code Examples/Quick Start
A good idea is to check out the [common mistakes during integration](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/COMMON-MISTAKES.md) documentation. Looking for example code and gotta go fast? No problem, got you [covered here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/QUICKSTART-EXAMPLES.md).

## Multi-threading
### Strategy
The best-known strategy is to use ENet in an independent I/O thread. This can be achieved by using Threads and enqueuing packets to be sent and received back and forth via ConcurrentQueues, for example. RingBuffers and Disruptors are also solid performance options too. Use whatever queue system you feel comfortable with, just make sure you empty the queues as fast as possible in your applications.

A real world example is Oiran Studio's [Ignorance](https://github.com/SoftwareGuy/Ignorance) transport which uses this ENET-CSharp fork via a Threaded Implementation to ensure the network threads run as fast as ENET can pump.

### Unity Warning
Threading in Unity was problematic but later versions (2018.3+) have proven to be fine. Please beware that using Threads inside a Unity environment can be problematic and can lead to the Unity Editor or built games randomly crashing without any warning. Use them with caution!

### Thread Safety
In general, ENet is not thread-safe, but some of its functions can be used safely if the user is careful enough:

- The `Packet` structure and its functions are safe until a packet is only moving across threads by value and a custom memory allocator is not used.

- `Peer.ID`: As soon as a pointer to a peer was obtained from the native side, the ID will be cached in the `Peer` structure for further actions with objects that assigned to that ID. The `Peer` structure can be moved across threads by value, but its functions are not thread-safe because data in memory may change by the servicing functions in another thread.

- `Library.Time`: utilizes atomic primitives internally for managing local monotonic time.

### API Documentation
--------
See `DOCUMENTATION.md` [here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/DOCUMENTATION.md).

### Supporters
--------
This fork is used by and supported by [Oiran Studio](http://www.oiran.studio).

<p align="left"> 
  <img src="http://www.oiran.studio/OiranFanFinal_Colour_Mini.png" alt="Oiran Studio Logo">
</p>

### Credits

- Coburn
- c6burns
- Katori
- Mirror Team & Discord Members

#### Some thanks to:
- Vincenzo from Flying Squirrel Entertainment
- lsalzman for the original enet repository
- nxrighthere
