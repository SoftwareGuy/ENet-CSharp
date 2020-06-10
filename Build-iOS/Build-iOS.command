#!/bin/bash
# CMake-powered script for compiling iOS builds of ENET 
# Script written by Coburn (SoftwareGuy) as part of the forked
# version of upstream ENET-CSharp tree.
# Licensed under MIT. Don't be a code thief.

OLDDIR=$(pwd)
CMAKE=$(which cmake)
CODE_ROOT=$(pwd)
UPPER_ROOT="$(pwd)/.."
DEBUG_STATUS=0

# Change this to OS64 for ARM64 only builds, OS for ARMv7 + ARM64 builds
DEV_TYPE="OS"
# Change this for Release/Debug versions
BUILD_TYPE="Release"

# Banner
echo "-------------"
echo "iOS Build Script for ENET, by Coburn (SoftwareGuy)"
echo "Make sure you get the latest from http://github.com/SoftwareGuy/ENet-CSharp"
echo "This script is beta quality and may break. Fixes welcome. Report them on the git."
echo "-------------"

# Phase 1
if [ -d build ] 
then 
	echo "Removing directory contents for a clean iOS build"
	rm -vrf build/*
else
	echo "Making directory for iOS Building..."
	mkdir build
fi

# Phase 2
# cd build

if [ -f $CMAKE ]
then
	echo "Setting up Xcode project for building..."
	
	if [ $BUILD_TYPE == "Debug" ]
	then
		echo "*** DEBUG TARGET: RESULTING LIBRARY WILL BE A DEBUG BUILD ***"
		echo ""
		DEBUG_STATUS=1
	fi
	
	cmake $CODE_ROOT -B$CODE_ROOT/build -G Xcode -DCMAKE_TOOLCHAIN_FILE=$UPPER_ROOT/MobileToolchains/ios.toolchain.cmake -DPLATFORM=OS -DENABLE_ARC=0 -DENABLE_VISIBILITY=0 -DENET_DEBUG=$DEBUG_STATUS -DENET_STATIC=1 -DENET_SHARED=0 -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO	
	
	if [ $? -eq 0 ] 
	then
		# Phase 3
		cd $CODE_ROOT/build

		if [ -f $(which xcodebuild) ] 
		then
			[ ! -d Release-iphoneos ] && rm -rvf Release-iphoneos && mkdir Release-iphoneos
			[ ! -d Debug-iphoneos ] && rm -rvf Debug-iphoneos && mkdir Debug-iphoneos
			xcodebuild -configuration $BUILD_TYPE
		
			if [ $? -eq 0 ]
			then
				echo "*** SUCCESSFUL BUILD! ***"
				echo ""
				echo "Good show, good show. Nicely done."
				echo "You'll find the static library under the respective folder, "
				echo "ie. Release-iphoneos or Debug-iphoneos . You may also want "
				echo "to run a 'lipo -archs libenet.a' check on that file to "
				echo "ensure that your architecture has been compiled in. "
			else 
				echo "*** ERROR: XCode Build Failed! Check the logs and "
				echo "make sure you have updated XCode. It might be simple "
				echo "fix, but it might also be something complex."
			fi
		else
			echo "*** ERROR: You don't seem to have XCode installed correctly!"
			echo "*** How do you expect this script to compile ENET?"
		fi

	else
		echo "*** ERROR: CMake reported a failure. Sorry, but we can't continue!"
		echo "*** Hint: Check the logs and see if it's an easy fix. Otherwise, "
		echo "*** file a bug report on the GitHub with what happened."
	fi
else
	echo "*** ERROR: CMake is not present on your device!"
	echo "*** You probably need to install either the XCode Command Line tools, "
	echo "*** or grab a third party package manager like Homebrew and install "
	echo "*** a copy of CMake that way. Sorry, but we can't continue!"
fi

# Get back to the directory you were in.
cd $pwd

# Bye bye.
echo ""
echo "Thanks for using SoftwareGuy's fork of ENet-CSharp!"
echo "Support the fork at http://github.com/SoftwareGuy/ENet-CSharp"
