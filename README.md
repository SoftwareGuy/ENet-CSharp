<p align="center"> 
  <img src="https://i.imgur.com/CxkUxTs.png" alt="alt logo">
</p>

[![Ko-Fi](https://img.shields.io/badge/Donate-Ko--Fi-red)](https://ko-fi.com/coburn) 
[![PayPal](https://img.shields.io/badge/Donate-PayPal-blue)](https://paypal.me/coburn64)
![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)
![Master Build](https://github.com/SoftwareGuy/ENet-CSharp/workflows/Master%20Build/badge.svg)

_**Please consider a donation (see the Ko-Fi button above) if this project is useful to you.**_

## What's this?

In short, this is an independent ENet native implementation with a modified protocol for C, C++, C#, and other languages.
The native C library code (although condensed) included in both this fork and upstream uses is located [here](https://github.com/lsalzman/enet).

### Why another fork?
This fork started since *nxrighthere*'s repository was originally archived, disabling the ability to report issues and submit pull requests.

Due to this, I forked his repository manually and this is the result. As a result, developers can ask questions about Enet, get answers and submit pull requests to improve the implementation.

This repository might not always have the latest version of the implementation from upstream, as careful integration of fork-specific features needs to be taken. However, I will try to keep it in sync with upstream as much as possible.

## Native Library Features

- Enhanced debugging functionality, including piping messages to console or log file (default behaviour)
- Lightweight and straightforward
- Low resource consumption
- Dual-stack IPv4/IPv6 support
- Connection management, Sequencing, Channels, Reliability, Fragmentation, Reassembly
- Aggregation
- Adaptability and portability

## Upstream Compatibility
In theory, upstream binaries can be used with this fork unless things change dramatically. To err on the safe side, use the automatic builds located on the release page.

In short: just use the automatic build binaries in [Releases](https://github.com/SoftwareGuy/ENet-CSharp/releases).

## Obtaining Native Libraries

### Easy Mode

You can get precompiled binaries for use with this fork by checking out the [Releases](https://github.com/SoftwareGuy/ENet-CSharp/releases) page.

### Hard Mode

If you don't want to take the automatically built libraries in the releases section, you can use the Visual Studio MS Build engine to build a binary for your platform(s).

However the following will be oriented for power users and command line heroes, and requires NET Core SDK 2.2 to work correctly.

#### Desktop Compiling

- **Windows:** Make sure you have Visual Studio 2017 or newer installed with C++ Development Support, a recent Windows SDK and CMake. You may need to install [CMake 3.16+ from Kitware](https://cmake.org/download/) as it *sometimes* doesn't get automatically installed with Visual Studio.

- **MacOS:** You'll need Xcode, which is available from the Mac App Store or the Apple Developer Portal. Make sure you also have the Apple Xcode CLI Tools installed.

- **Linux:** Make sure you have your repositories' `build-essential` and `cmake` package installed. On Debian and Ubuntu-based distros, you can do `sudo apt -y build-essential cmake` to install the required packages.

#### Mobile Compiling

- **Android:** Ensure you have the Android NDK installed. Easiest way to do this to go into `Sources/Native` and run when `ndk-build`. A fresh batch of ENET binaries should then be spat out, which can be used in your project.

- **Apple iOS:** Using **Terminal.app** on your MacOS device, navigate to the `Build-iOS` directory and run the command file found inside. You might need to make it executable, however. It will try to auto-pilot a build for you, just make sure you have CMake installed for MacOS and a recent Xcode installation. Library code signing will be disabled for the build.

#### Console Compiling

- **Microsoft Xbox One:** Limited testing says the Windows library should work fine, unless the Windows-based Xbox OS uses a different SDK. However, I do not have access to an XB1 Developer Kit.

- **Nintendo Switch:** A old guide is available [here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/BUILD-FOR-SWITCH.txt). However, it will require patches to work with the Switch SDK. Since said SDK is under NDA, limited public info can be provided.

- **Playstation 4/Vita:** I am not planning to add support for the PS4/PSVita to this repository. The native layer will most likely require patches to use on Sony's BSD-based PlayStation OS.

- **Other console not listed:** Open a issue ticket and I'll gladly add your steps for your platform here.

#### Recipe for victory

- Clone a fresh copy of this Git Repo somewhere on your workstation's filesystem.
- Open a command prompt/terminal and change directory into the newly cloned git repository.
- Run `dotnet build`. A **Debug** release will be generated, unless you read the next dot point.
- **Protip:** You can append `-c Release` or `-c Debug` to your `dotnet build` command to build a release binary or a debug binary of ENET's C library. At the moment, the default build is a Debug build.

You will see a [Ignorance](https://github.com/SoftwareGuy/Ignorance) banner fly by and the compile will start. CMake will then be invoked and configure the build after inspecting your environment. If all is well, a binary blob inside the `Unity/Plugins` directory will be generated.

If it does not compile successfully, read the error messages it provides and file an issue ticket if you are not able to solve it yourself.

On Windows, this freshly baked library will be called `enet.dll` DLL, on Mac it will be `libenet.bundle` and on Linux it will be a shared object (`libenet.so`). This can be used with Unity or other applications like a C# NET Core application or C/C++ apps.
Unity users should take note that you may need to rename `libenet.bundle` to `libenet.dylib` for Unity to load the plugin at runtime. 

#### Rebuilding the native binaries

Inside the directory that you cloned the repo to, run:

- `dotnet clean`
- `dotnet build` (don't forget about the `-c Release/Debug` argument as mentioned earlier!)

It is recommended to clean the repository work space before building.

### Testing

- `dotnet test` will run some sanity checks and make sure ENet initializes, data is received and sent correctly, etc. Right now tests are limited, but eventually will hopefully test the basics of ENet to ensure nothing is broken.

## Usage

- Please make sure you initialize ENet first before doing anything by calling the `ENet.Library.Initialize();` function.
	- This returns **true** if successful, if not it will return **false**. 
	- You can use this to gracefully quit your application should it fail to initialize, for example.
- Once you are done with Enet, deinitialize the library using `ENet.Library.Deinitialize();` function to ensure a clean shutdown.
- Using Enet-CSharp inside the Unity Engine is almost the same as in the standard .NET environment, except that the console functions must be replaced with functions provided by Unity.
	- If the `Host.Service()` will be called in a game loop, then make sure that the timeout parameter set to 0 which means non-blocking. 
	- Also make sure Unity runs in the background by enabling the ***Run in Background*** player setting.

### Code Examples/Quick Start

- A good idea is to check out the [common mistakes during integration](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/COMMON-MISTAKES.md) documentation. 
- There's also some [quickstart examples](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/QUICKSTART-EXAMPLES.md) to make your Enet life easier.

## API Documentation

- Read [DOCUMENTATION.md](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/DOCUMENTATION.md) as it is quite detailed.

## Multi-threaded Enet Implementation

### Strategy
The best-known strategy is to use ENet in an independent I/O thread. This can be achieved by using Threads as well as ConcurrentQueues, RingBuffers and Disruptors, for example. 

You can use whatever system you are comfortable with, just make sure you keep ENet pumping as fast as possible in your application. Not pumping fast enough will cause Enet to become backlogged/congested, and this will hurt performance and network throughput.

A real world example is Oiran Studio's [Ignorance](https://github.com/SoftwareGuy/Ignorance) transport which uses ConcurrentQueues for high performance transport I/O.

### Thread Safety
In general, ENet is not thread-safe, but some of its functions can be used safely if the user is careful enough:

- The `Packet` structure and its functions are safe until a packet is only moving across threads by value and a custom memory allocator is not used.

- `Peer.ID`: As soon as a pointer to a peer was obtained from the native side, the ID will be cached in the `Peer` structure for further actions with objects that assigned to that ID. The `Peer` structure can be moved across threads by value, but its functions are not thread-safe because data in memory may change by the servicing functions in another thread.

- `Library.Time`: utilizes atomic primitives internally for managing local monotonic time.


## Supporters

Enet-CSharp is supported by, used internally and mantained by [Oiran Studio](http://www.oiran.studio).

<p align="left"> 
  <img src="http://www.oiran.studio/OiranFanFinal_Colour_Mini.png" alt="Oiran Studio Logo">
</p>

## Credits

- Coburn, c6burns, Katori, Mirror development team and discord members, repository contributors and coffee donators
- Vincenzo from Flying Squirrel Entertainment ("resident enet guy"), lsalzman for the original Enet native repository
- nxrighthere for the upstream Enet-CSharp repository in which this fork started from