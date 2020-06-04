#ifndef ENET_IOSFIXES_H
#define ENET_IOSFIXES_H

// Standard things.
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>

// Apple-related things.
#include <mach/clock.h>
#include <mach/mach.h>
#include <Availability.h>

// Fix for a pre iOS 10 bug where clock_get_time is a stub.
// iOS 9.3.x is known to be affected on iPad Gen 2, iPhone 4S, etc.
// clock_get_time became present post iOS 10.
int preiOS10_clock_get_time(int X, struct timespec* ts) {
    clock_serv_t cclock;
    mach_timespec_t mts;

    host_get_clock_service(mach_host_self(), SYSTEM_CLOCK, &cclock);
    clock_get_time(cclock, &mts);
    mach_port_deallocate(mach_task_self(), cclock);

    ts->tv_sec = mts.tv_sec;
    ts->tv_nsec = mts.tv_nsec;

    return 0;
}
#endif