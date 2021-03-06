#!/bin/bash
# Script modified from upstream at the following URL:
# https://github.com/nxrighthere/ENet-CSharp/blob/master/Source/Native/build-ios.sh
# Original portions by JohannesDeml, modifications by Coburn.

# Cache this for later.
# Point sysdir to iOS SDK
RELEASE_SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
SIMULATOR_SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
WORKSPACE="$(pwd)"
OUTPUT="$WORKSPACE/Binaries"
X64_SIMULATOR_STAGING="$WORKSPACE/x86_64-apple-ios-simulator"
ARM64_STAGING="$WORKSPACE/arm64-apple-ios"
ARMV7_STAGING="$WORKSPACE/armv7-apple-ios"

# Function declaration
create_enet_symlink() {
	# Only symlink if we don't have one already
	if [ ! -d "Sources" ]; then 
		# Symlink work directory sources.
		ln -s "$WORKSPACE/../Source/Native" "Sources"
		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to make symlink to ENet source code. Did you git pull this correctly? Build script aborted."
			exit $?
		fi
	fi
}

make_enet_directories() { 
	# Output
	if [ ! -d "$OUTPUT" ]; then
		mkdir "$OUTPUT"

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to make staging directory for x64 Simulator. Build script aborted."
			exit $?	
		fi
	else
		rm -rfv "$OUTPUT"/*

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to delete files inside output directory. Build script aborted."
			exit $?	
		fi
	fi
	
	# Simulator
	if [ ! -d "$X64_SIMULATOR_STAGING" ]; then
		# Make it.
		mkdir "$X64_SIMULATOR_STAGING"

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to make staging directory for x64 Simulator. Build script aborted."
			exit $?	
		fi
	else 
		# Purge it.
		echo "Cleaning out existing x64 Simulator staging directory."
		rm -rfv "$X64_SIMULATOR_STAGING"/*

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to delete files inside staging directory. Build script aborted."
			exit $?	
		fi
	fi
	
	# ARMv7
	if [ ! -d "$ARMV7_STAGING" ]; then
		# Make it.
		mkdir "$ARMV7_STAGING"

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to make staging directory for ARMv7. Build script aborted."
			exit $?	
		fi
	else 
		# Purge it.
		echo "Cleaning out existing ARMv7 staging directory."
		rm -rfv "$ARMV7_STAGING"/*

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to delete files inside staging directory. Build script aborted."
			exit $?	
		fi
	fi
	
	# ARM64
	if [ ! -d "$ARM64_STAGING" ]; then
		# Make it.
		mkdir "$ARM64_STAGING"

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to make staging directory for ARM64. Build script aborted."
			exit $?	
		fi
	else 
		# Purge it.
		echo "Cleaning out existing ARM64 staging directory."
		rm -rfv "$ARM64_STAGING"/*

		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to delete files inside staging directory. Build script aborted."
			exit $?	
		fi
	fi
}

compile_enet_x64simulator () {
	echo "Start compiling x64 Simulator"
	export SDKROOT=$SIMULATOR_SDKROOT

	cd "$X64_SIMULATOR_STAGING"
	# Pre-clean
	rm -vf *.a *.o
	
	create_enet_symlink
	
	# Release Binaries
	gcc -c Sources/enet.c -fembed-bitcode -target x86_64-apple-ios-simulator
	if [ $? -ne 0 ]; then
		echo "ERROR: Compile step resulted in failure."
		exit $?
	fi

	# Create static library
	libtool -static enet.o -o libenet-release-simulator64.a
	if [ $? -ne 0 ]; then
		echo "ERROR: Libtool step resulted in failure."
		exit $?
	fi

	# Cleanup
	rm -vf *.o
	
	# Debug Binaries
	gcc -DENET_DEBUG=1 -c Sources/enet.c -fembed-bitcode -target x86_64-apple-ios-simulator
	if [ $? -ne 0 ]; then
		echo "ERROR: Compile step resulted in failure."
		exit $?
	fi
	libtool -static enet.o -o libenet-debug-simulator64.a
		if [ $? -ne 0 ]; then
		echo "ERROR: Libtool step resulted in failure."
		exit $?
	fi

	# Copy.
	cp -v *.a "$OUTPUT"
}

compile_enet_armv7 () {
	echo "Start compiling ARMv7"
	export SDKROOT=$RELEASE_SDKROOT
	cd "$ARMV7_STAGING"
	
	# Pre-clean
	rm -vf *.a *.o
	
	create_enet_symlink
	
	# Release Binaries
	gcc -c Sources/enet.c -fembed-bitcode -target armv7-apple-ios
	if [ $? -ne 0 ]; then
		echo "ERROR: Compile step resulted in failure."
		exit $?
	fi

	# Create static library
	libtool -static enet.o -o libenet-release-armv7.a
	if [ $? -ne 0 ]; then
		echo "ERROR: Libtool step resulted in failure."
		exit $?
	fi
	
	# Cleanup
	rm -vf *.o
	
	# Debug Binaries
	gcc -DENET_DEBUG=1 -c Sources/enet.c -fembed-bitcode -target armv7-apple-ios
	if [ $? -ne 0 ]; then
		echo "ERROR: Compile step resulted in failure."
		exit $?
	fi

	libtool -static enet.o -o libenet-debug-armv7.a
	if [ $? -ne 0 ]; then
		echo "ERROR: Libtool step resulted in failure."
		exit $?
	fi

	# Copy.
	cp -v *.a "$OUTPUT"
}

compile_enet_arm64 () {
	echo "Start compiling ARM64"
	export SDKROOT=$RELEASE_SDKROOT
	cd "$ARM64_STAGING"
	
	# Pre-clean
	rm -vf *.a *.o
	
	create_enet_symlink
		
	# Release Binaries
	gcc -c Sources/enet.c -fembed-bitcode -target arm64-apple-ios
	if [ $? -ne 0 ]; then
		echo "ERROR: Compile step resulted in failure."
		exit $?
	fi

	# Create static library
	libtool -static enet.o -o libenet-release-arm64.a
	if [ $? -ne 0 ]; then
		echo "ERROR: Libtool step resulted in failure."
		exit $?
	fi

	# Cleanup
	rm -v *.o
	
	# Debug Binaries
	gcc -DENET_DEBUG=1 -c Sources/enet.c -fembed-bitcode -target arm64-apple-ios
	if [ $? -ne 0 ]; then
		echo "ERROR: Compile step resulted in failure."
		exit $?
	fi

	libtool -static enet.o -o libenet-debug-arm64.a
	if [ $? -ne 0 ]; then
		echo "ERROR: Libtool step resulted in failure."
		exit $?
	fi

	# Copy.
	cp -v *.a "$OUTPUT"
}

compress_and_exfil() {
	# Good 'ol Zip.
	cd $OUTPUT
	
	if [ $? -ne 0 ]; then
		echo "WARNING: Looks like we can't enter the output directory, skipping compression phase"
		return
	fi
	
	echo "About to compress compiled binaries."
	zip -v -9 -j "libenet-combo-iOS.zip" *.a
	
	if [ $? -ne 0 ]; then
		echo "WARNING: Looks like the compression step failed, continuing as this is not fatal"
	fi
}

# Make staging directories and build.
make_enet_directories
compile_enet_x64simulator
compile_enet_arm64
compile_enet_armv7

# Compress the goods.
compress_and_exfil

FINAL_STAND=$?

echo "Build script has finished."
exit $FINAL_STAND
