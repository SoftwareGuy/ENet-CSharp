#ifndef ENET_LOGGING_H
#define ENET_LOGGING_H

// Include basic things used for our logging facility.
#include <stdarg.h>
#include <stdio.h>

// Apple Specific things.
#if __APPLE__
	#include <TargetConditionals.h> // <-- Not needed?
    #include <asl.h>
#endif

// TODO: Make better filenames; ie. enet_log.pid.txt
#define ENET_LOG_FILE "enet_debug.log"

static FILE *enet_log_fp = NULL;

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
#	define ENET_LOG_TRACE(...) enet_log(ENET_LOG_TYPE_TRACE, __FUNCTION__, __LINE__, __VA_ARGS__)
#	define ENET_LOG_ERROR(...) enet_log(ENET_LOG_TYPE_ERROR, __FUNCTION__, __LINE__, __VA_ARGS__)
#else
#	define ENET_LOG_TRACE(...) ((void)0)
#	define ENET_LOG_ERROR(...) ((void)0)
#endif

static inline void enet_log(enum enet_log_type type, const char *func, int line, const char *fmt, ...)
{
	va_list args;
	time_t tstamp = time(NULL);
	struct tm *local_time = localtime(&tstamp);
	char time_buf[64];

#if __APPLE__
	// Logging has changed, hopefully this will dump it into your Console.app
	// on macOS/iOS.
    char logStringBuf[512];
    
	// Prefix
    va_start(args, fmt);
    vsprintf(logStringBuf, fmt, args);
    asl_log(NULL, NULL, ASL_LEVEL_ERR, "%s", logStringBuf);
	va_end(args);
#else
    // Timestamp
    time_buf[strftime(time_buf, sizeof(time_buf), "%Y-%m-%d %H:%M:%S", local_time)] = '\0';
    
	// Open the log file
	if (!enet_log_fp) enet_log_fp = fopen(ENET_LOG_FILE, "a");
	if (!enet_log_fp) return;

    // Print the log into the file
	fprintf(enet_log_fp, "%s [%s] [%s:%d] ", time_buf, enet_log_type_names[type], func, line);
	va_start(args, fmt);
	vfprintf(enet_log_fp, fmt, args);
	va_end(args);
	fprintf(enet_log_fp, "\n");
    // Close the file
	fflush(enet_log_fp);
#endif

}
#endif