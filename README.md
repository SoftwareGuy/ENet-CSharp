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
The original C library both this fork and upstreams' fork is based on is located [here](https://github.com/lsalzman/enet).

A slightly longer description is that this is a improved and refactored version of ENET-CSharp. A fork of a fork, if you want to call it that. This fork started since the upstream fork was originally archived, disabling the ability to report issues and submit pull requests.
The upstream developer also made some questionable choices (including blacklisting/blocking myself and numerous others). As a result, this fork was made and allows developers to ask questions and submit pull requests to improve the implementation.

## Native Library Features

- Lightweight and straightforward
- Low resource consumption
- Dual-stack IPv4/IPv6 support
- Connection management, Sequencing, Channels, Reliability, Fragmentation, Reassembly
- Aggregation
- Adaptability and portability

## Upstream Compatibility

Do not use the upstream binaries with this fork. While it *may* work, it is best to err on the side of caution and play it safe.

## Obtaining the native libraries

### Easy Mode

You can get precompiled binaries for use with this fork by checking out the [Releases](https://github.com/SoftwareGuy/ENet-CSharp/releases) page.

### Hard Mode

If you don't want to take the automatically built libraries in the releases section, you can use the Visual Studio MS Build engine to build a binary for your platform(s).

However the following will be oriented for power users and command line heroes, and requires NET Core SDK 2.2 to work correctly.

#### Compiling for Desktop

- **Windows:** Make sure you have Visual Studio '17 or '19 installed with C++ Development Support, a recent Windows SDK and CMake. You may need to install [CMake from Kitware](https://cmake.org/download/) as it *sometimes* doesn't get automatically installed with Visual Studio. Version 3.16 or newer works fine.

- **MacOS:** You'll need Xcode (available from the Mac App Store or the Apple Developer Portal). Make sure you also have Apple Xcode CLI Tools installed.

- **Linux:** Make sure you have your repositories' `build-essential` and `cmake` package installed. On Debian and Ubuntu-based distros, you can do `sudo apt -y build-essential cmake` to install the required packages.

#### Compiling for Mobile

- **Android:** Ensure you have the Android NDK installed. Easiest way to do this to go into `Sources/Native` and run when `ndk-build`. A fresh batch of ENET binaries should then be spat out, which can be used in your project.

- **Apple iOS:** Using **Terminal.app** on your MacOS device, navigate to the `Build-iOS` directory and run the command file found inside. You might need to make it executable, however. It will try to auto-pilot a build for you, just make sure you have CMake installed for MacOS and a recent Xcode installation. Library code signing will be disabled for the build.

#### Compiling for Console

- **Microsoft Xbox One:** Limited testing says the Windows library should work fine, unless the Windows-based Xbox OS uses a different SDK. However, I do not have access to an XB1 Developer Kit.

- **Nintendo Switch:** A old guide is available [here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/BUILD-FOR-SWITCH.txt). However, it will require patches to work with the Switch SDK. Since said SDK is under NDA, limited public info can be provided.

- **Playstation 4/Vita:** I am not planning to add support for the PS4/PSVita to this repository. The native layer will most likely require patches to use on Sony's BSD-based PlayStation OS.

- **Other console not listed:** Open a issue ticket and I'll gladly add your steps for your platform here.

#### Recipe for victory

- Clone a fresh copy of this Git Repo somewhere on your workstation's filesystem.
- Open a command prompt/terminal and change directory into the newly cloned git repository.
- Run `dotnet build`. 
- **Protip:** You can append `-c Release` or `-c Debug` to your `dotnet build` command to build a release binary or a debug binary of ENET's C library. At the moment, the default build is a Debug build.

You will see [Ignorance](https://github.com/SoftwareGuy/Ignorance) ASCII art fly by and the compile will start. CMake will fire up, configure itself after inspecting your build environment and hopefully spit out a binary blob inside a `Unity/Plugins` directory. 

On Windows, this freshly baked library will be a DLL, on Mac it will be a `.bundle` file and on Linux it will be a shared object (`.so`). This can be used with Unity or other applications like a C# NET Core application or C/C++ apps.

#### Rebuilding the native binaries

Inside the directory that you cloned the repo to, run:

- `dotnet clean`
- `dotnet build` (don't forget about the `-c Release/Debug` argument as mentioned earlier!)

It is recommended to clean the repository work space before building.

### Testing

- `dotnet test` will run some sanity checks and make sure ENET initializes, data is received and sent correctly, etc.

## Usage


- Initialize ENET first before doing anything by calling the `ENet.Library.Initialize();` function. It will return false on failure, return true on success. You can use this to gracefully quit your application should it fail to initialize, for example.
- Once you are done, deinitialize the library using `ENet.Library.Deinitialize();` function.
- Unity Engine usage is almost the same as in the .NET environment, except that the console functions must be replaced with functions provided by Unity. If the `Host.Service()` will be called in a game loop, then make sure that the timeout parameter set to 0 which means non-blocking. Also make sure Unity runs in the background by enabling the ***Run in Background*** player setting.

### Code Examples/Quick Start

A good idea is to check out the [common mistakes during integration](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/COMMON-MISTAKES.md) documentation. 

Looking for example code and gotta go fast? No problem, got you [covered here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/QUICKSTART-EXAMPLES.md).

## API Documentation

See `DOCUMENTATION.md` [here](https://github.com/SoftwareGuy/ENet-CSharp/blob/master/DOCUMENTATION.md).

## Enet and multi-threading

### Strategy
The best-known strategy is to use ENet in an independent I/O thread. This can be achieved by using Threads and enqueuing packets to be sent and received back and forth via ConcurrentQueues, for example. RingBuffers and Disruptors are also solid performance options too. Use whatever queue system you feel comfortable with, just make sure you empty the queues as fast as possible in your applications.

A real world example is Oiran Studio's [Ignorance](https://github.com/SoftwareGuy/Ignorance) transport which uses ConcurrentQueues for high performance transport I/O.

### Thread Safety
In general, ENet is not thread-safe, but some of its functions can be used safely if the user is careful enough:

- The `Packet` structure and its functions are safe until a packet is only moving across threads by value and a custom memory allocator is not used.

- `Peer.ID`: As soon as a pointer to a peer was obtained from the native side, the ID will be cached in the `Peer` structure for further actions with objects that assigned to that ID. The `Peer` structure can be moved across threads by value, but its functions are not thread-safe because data in memory may change by the servicing functions in another thread.

- `Library.Time`: utilizes atomic primitives internally for managing local monotonic time.


### Supporters

This fork is supported, used and mantained by [Oiran Studio](http://www.oiran.studio).

<p align="left"> 
  <img src="http://www.oiran.studio/OiranFanFinal_Colour_Mini.png" alt="Oiran Studio Logo">
</p>

### Credits

- Coburn
- c6burns
- Katori
- Mirror Team & Discord Members
- Vincenzo from Flying Squirrel Entertainment ("resident enet guy")
- lsalzman for the original Enet native repository
- nxrighthere for the upstream fork
