@echo off
rem Oh hey there. Coburn here.
rem You might be thinking what's this file gotta
rem do with ENet? Well, let's just say I've got
rem the shits with the fucking GitHub actions
rem system. Syntax error without any fucking additional
rem information. No "expecting ..." or "... not allowed here",
rem just fucking syntax error, lol. And there's no Github-flavoured
rem YAML parsers online, so yeah. Poor 'ol me can't figure it out.
rem 
rem Anyway, that ends here. What this script does is mainly runs
rem the build process as part of the CI pipeline. Hopefully that
rem means I can just use this script to run the Microsoft Windows
rem builds, because I've had the shits as mentioned above trying to
rem use YAML files. YAML can GTFO until further notice.
set %_OutputFolder%=%1
PATH=C:\Program Files\7-Zip;%PATH%

rem Make release and debug folders.
mkdir %_OutputFolder%\ReleaseOut
mkdir %_OutputFolder%\DebugOut

echo Preparing Debug Build
dotnet clean
dotnet build

echo Stashing...
copy Unity\Plugins\x86_64\enet.dll %_OutputFolder%\DebugOut

echo Preparing Release Build
dotnet clean
dotnet build -c Release

echo Stashing...
copy Unity\Plugins\x86_64\enet.dll %_OutputFolder%\ReleaseOut

echo Compressing...
7z a %_OutputFolder%\DebugOut\enet.dll %_OutputFolder%\DebugOut\Debug.zip
7z a %_OutputFolder%\ReleaseOut\enet.dll %_OutputFolder%\ReleaseOut\Release.zip

echo BUILD SCRIPT EXITING