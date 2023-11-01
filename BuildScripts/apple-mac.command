#!/bin/bash
# MacOS flavoured version of Coburn's autobuild script, since YAML
# can go suck it.

# Cache variables.
WORKDIR=$(pwd)

# Make work directories.
mkdir -p $WORKDIR/ReleaseOut
mkdir -p $WORKDIR/DebugOut

echo Preparing build environment...
dotnet clean

echo Building Debug Library...
dotnet build

echo Stashing...
cp -v Unity/Plugins/x86_64/* $WORKDIR/DebugOut

echo Cleaning up...
dotnet clean
rm -vf Unity/Plugins/x86_64/*

echo Building Release Library...
dotnet build -c Release

echo Stashing
cp -v Unity/Plugins/x86_64/* $WORKDIR/ReleaseOut

echo Compressing...
cd $WORKDIR/ReleaseOut && zip -9 Release.zip libenet.bundle
cd $WORKDIR/DebugOut && zip -9 Debug.zip libenet.bundle

echo End of Build Script. Have a nice day.
exit $?