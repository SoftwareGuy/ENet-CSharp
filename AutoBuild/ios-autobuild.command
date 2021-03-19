#!/bin/bash
# Script modified from upstream at the following URL:
# https://github.com/nxrighthere/ENet-CSharp/blob/master/Source/Native/build-ios.sh
# Original portions by JohannesDeml, modifications by Coburn.

# Point sysdir to iOS SDK
export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
# Cache this for later.
WORKSPACE=$(pwd)
X64_SIMULATOR_STAGING="$WORKSPACE/x86_64-apple-ios-simulator"
ARM64_STAGING="$WORKSPACE/arm64-apple-ios"
ARMV7_STAGING="$WORKSPACE/armv7-apple-ios"

# Function declaration
create_enet_symlink() {
	# Only symlink if we don't have one already
	if [ ! -d "Sources" ]; then 
		# Symlink work directory sources.
		ln -s Sources $WORKSPACE/../Source/Native
		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to make symlink to ENet source code. Did you git pull this correctly? Build script aborted."
			exit $?
		fi
	fi
}

compile_enet_x64simulator () {
	cd $X64_SIMULATOR_STAGING
	
	# Release Binaries
	gcc -c Sources/enet.c -fembed-bitcode -target x86_64-apple-ios-simulator
	# Create static library
	libtool -static enet.o -o libenet-release-simulator64.a
	
	# Cleanup
	rm -v *.o
	
	# Debug Binaries
	gcc -DENET_DEBUG=1 -c Sources/enet.c -fembed-bitcode -target x86_64-apple-ios-simulator
	libtool -static enet.o -o libenet-debug-simulator64.a
	
	# Copy.
	cp -v *.a $WORKSPACE
}

compile_enet_armv7 () {
	cd $ARMV7_STAGING
	# Pre-clean
	rm -v *.a *.o
	
	create_enet_symlink()
	
	# Release Binaries
	gcc -c Sources/enet.c -fembed-bitcode -target armv7-apple-ios
	# Create static library
	libtool -static enet.o -o libenet-release-armv7.a
	
	# Cleanup
	rm -v *.o
	
	# Debug Binaries
	gcc -DENET_DEBUG=1 -c Sources/enet.c -fembed-bitcode -target armv7-apple-ios
	libtool -static enet.o -o libenet-debug-armv7.a
	
	# Copy.
	cp -v *.a $WORKSPACE
}

compile_enet_arm64 () {
	cd $ARM64_STAGING
	
	# Pre-clean
	rm -v *.a *.o
	
	create_enet_symlink()
		
	# Release Binaries
	gcc -c Sources/enet.c -fembed-bitcode -target arm64-apple-ios
	# Create static library
	libtool -static enet.o -o libenet-release-arm64.a
	
	# Cleanup
	rm -v *.o
	
	# Debug Binaries
	gcc -DENET_DEBUG=1 -c Sources/enet.c -fembed-bitcode -target arm64-apple-ios
	libtool -static enet.o -o libenet-debug-arm64.a
	
	# Copy.
	cp -v *.a $WORKSPACE
}

# ln -s Sources $WORKSPACE/../Source/Native

# Make staging directories and build.
mkdir $ARM64_STAGING

if [ $? -ne 0 ]; then
	echo "ERROR: Failed to make staging directory for ARM64. Build script aborted."
	exit $?
else 
	compile_enet_arm64()
fi

mkdir $ARMV7_STAGING
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to make staging directory for ARMv7. Build script aborted."
	exit $?
else 
	compile_enet_armv7()
fi

mkdir $X64_SIMULATOR_STAGING
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to make staging directory for iOS Simulator (x64). Build script aborted."
	exit $?
else 
	compile_enet_x64simulator()
fi

FINAL_STAND=$?

echo "Build script has finished."
exit $FINAL_STAND