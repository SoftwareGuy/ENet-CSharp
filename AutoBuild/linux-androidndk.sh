#!/bin/bash
echo "Executing autobuild process for ENet-CSharp repository"
echo "Script written by SoftwareGuy (https://github.com/SoftwareGuy)"

echo "Retreiving paths"
WORKFILEPATH=`readlink -f "${BASH_SOURCE:-$0}"`
WORKPATH=`dirname "$WORKFILEPATH"`
SOURCEDIR=`dirname "$WORKPATH/../Source/Native/jni"`
OUTPUTDIR="$WORKPATH/Out"
DUMP="$HOME/Dump"

echo ""
echo "Script is located at '$WORKFILEPATH'"
echo "Script directory is located at '$WORKPATH'"
echo "Source code should be located at '$SOURCEDIR'"
echo "Grabbing tools if they don't exist already..."
echo ""

if [ ! -d $DUMP ]; then
        mkdir $DUMP
fi

if [ ! -f "$DUMP/android-ndk-r25c-linux.zip" ]; then
        wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip -O "$DUMP/android-ndk-r25c-linux.zip"

        if [ $? -ne 0 ]; then
                echo "Failure: Tools download failed. Aborting!"
                exit 1
        fi
fi

cd "$DUMP"

if [ ! -d "$DUMP/android-ndk-r25c" ]; then
        echo "Unpacking tools..."
        unzip -o android-ndk-r25c-linux.zip

        if [ $? -ne 0 ]; then
                echo "Failure: Tools unpack failed. Aborting!"
                exit 1
        fi
fi

PATH="$DUMP/android-ndk-r25c:$PATH"
cd $SOURCEDIR

echo "Output directory is set to '$OUTPUTDIR'."
echo "Compile: ENet Native (Non-debug version)"
if [ ! -d "$OUTPUTDIR/Release" ]; then
        mkdir -p "$OUTPUTDIR/Release"
fi
NDK_LIBS_OUT="$OUTPUTDIR/Release" ndk-build

echo "Compile: ENet Native (Debug version)"
if [ ! -d "$OUTPUTDIR/Debug" ]; then
        mkdir -p "$OUTPUTDIR/Debug"
fi
NDK_LIBS_OUT="$OUTPUTDIR/Debug" ENET_DEBUG=1 ndk-build

echo ""
echo "Complete!"
exit 0
