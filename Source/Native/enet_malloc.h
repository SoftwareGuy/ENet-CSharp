#ifndef ENET_ALLOC_H
#define ENET_ALLOC_H

#include <stdlib.h>

#ifndef ENET_MIMALLOC
static const char *enet_malloc_name_str = "malloc";
static inline void *enet_malloc(size_t size_in_bytes) { return malloc(size_in_bytes); }
static inline void enet_free(void *alloc) { free(alloc); }
#else
#   include "mimalloc.h"
static const char *enet_malloc_name_str = "mi_malloc";
static inline void *enet_malloc(size_t size_in_bytes) { return mi_malloc(size_in_bytes); }
static inline void enet_free(void *alloc) { mi_free(alloc); }
#endif

static inline const char *enet_malloc_name() { return enet_malloc_name_str; }

#endif
