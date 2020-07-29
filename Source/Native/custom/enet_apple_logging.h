#ifndef ENET_APPLE_LOGGING_H
#define ENET_APPLE_LOGGING_H
// Partly used from StackOverflow:
// https://stackoverflow.com/questions/8372484/nslog-style-debug-messages-from-c-code
// Only compile this in if we're on an Apple-based system.
#if __APPLE__
	#include <CoreFoundation/CoreFoundation.h>
	extern "C" void NSLog(CFStringRef format, ...);

	#define AppleNSLog(fmt, ...) \
	{ \
		NSLog(CFSTR(fmt), ##__VA_ARGS__); \
	}
#endif
#endif