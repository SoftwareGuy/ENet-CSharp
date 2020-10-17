#ifndef ENET_LOGGING_H
#define ENET_LOGGING_H

#include <stdarg.h>
#include <stdio.h>
#if __APPLE__
#include <TargetConditionals.h>
#endif

// TODO: Make better filenames; ie. enet_log.pid.txt
#define ENET_LOG_FILE "enet_debug.log"
static FILE* enet_log_fp = NULL;

enum enet_log_type
{
	ENET_LOG_TYPE_TRACE,
	ENET_LOG_TYPE_ERROR,
};

static const char *const enet_log_type_names[] = {
	[ENET_LOG_TYPE_TRACE] = "TRACE",
	[ENET_LOG_TYPE_ERROR] = "ERROR",
};

#if ENET_DEBUG
// Debug
#define ENET_LOG_TRACE(...) enet_log_to_file(ENET_LOG_TYPE_TRACE, __FUNCTION__, __LINE__, __VA_ARGS__)
#define ENET_LOG_ERROR(...) enet_log_to_file(ENET_LOG_TYPE_ERROR, __FUNCTION__, __LINE__, __VA_ARGS__)

static inline void enet_log_to_file(enum enet_log_type type, const char *func, int line, const char *fmt, ...)
{
	va_list args;
	time_t tstamp = time(NULL);
	struct tm *local_time = localtime(&tstamp);
	char time_buf[64];

	time_buf[strftime(time_buf, sizeof(time_buf), "%Y-%m-%d %H:%M:%S", local_time)] = '\0';

#if __ANDROID__ || (__APPLE__ && TARGET_OS_IPHONE)
	// iOS Debugging - Sandboxed logging can't write file. This might extend even into Android!
	// Can't write to files without the file permission... so don't do that if we're on Apple.
	// https://github.com/SoftwareGuy/ENet-CSharp/issues/15

	// Write the initial debug text to stdout.
	printf("%s [%s] [%s:%d] ", time_buf, enet_log_type_names[type], func, line);
	
	// Write our arguments and related stuff to stdout, then newline it.
	va_start(args, fmt);	
	vprintf(fmt, args);	
	va_end(args);
	printf("\n");

	// -- End logging for Android and Apple iOS -- //
#else
	// Open the log file, and if we can't, then short-circuit.
	if (!enet_log_fp) enet_log_fp = fopen(ENET_LOG_FILE, "a");
	if (!enet_log_fp) return;

	// Write the initial debug text to buffer.
	fprintf(enet_log_fp, "%s [%s] [%s:%d] ", time_buf, enet_log_type_names[type], func, line);
	
	// Write our arguments and related stuff to buffer.
	va_start(args, fmt);
	vfprintf(enet_log_fp, fmt, args);
	va_end(args);

	// Write new line marker, then flush and wrap up.
	fprintf(enet_log_fp, "\n");
	fflush(enet_log_fp);

	// -- End logging for other platforms -- //
#endif
}
#else
// We are not building a debug library, stub the functions.
#define ENET_LOG_TRACE(...) ((void)0)
#define ENET_LOG_ERROR(...) ((void)0)
#endif

// end ifndef
#endif