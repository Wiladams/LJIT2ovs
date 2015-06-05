
local ffi = require("ffi")

require ("openvswitch.util")

ffi.cdef[[
static const int __SIZEOF_PTHREAD_ATTR_T =56;
static const int __SIZEOF_PTHREAD_MUTEX_T =40;
static const int __SIZEOF_PTHREAD_MUTEXATTR_T =4;
static const int __SIZEOF_PTHREAD_COND_T =48;
static const int __SIZEOF_PTHREAD_CONDATTR_T =4;
static const int __SIZEOF_PTHREAD_RWLOCK_T =56;
static const int __SIZEOF_PTHREAD_RWLOCKATTR_T =8;
static const int __SIZEOF_PTHREAD_BARRIER_T =32;
static const int __SIZEOF_PTHREAD_BARRIERATTR_T =4;

typedef unsigned long int pthread_t;
typedef struct __pthread_internal_list
{
  struct __pthread_internal_list *__prev;
  struct __pthread_internal_list *__next;
} __pthread_list_t;
]]

ffi.cdef[[
typedef union
{
  struct __pthread_mutex_s
  {
    int __lock;
    unsigned int __count;
    int __owner;
//#ifdef __x86_64__
    unsigned int __nusers;
//#endif
    /* KIND must stay at this position in the structure to maintain
       binary compatibility.  */
    int __kind;
//#ifdef __x86_64__
    short __spins;
    short __elision;
    __pthread_list_t __list;
//# define __PTHREAD_MUTEX_HAVE_PREV  1
//# define __PTHREAD_MUTEX_HAVE_ELISION   1

  } __data;
  char __size[__SIZEOF_PTHREAD_MUTEX_T];
  long int __align;
} pthread_mutex_t;
]]

ffi.cdef[[
typedef union
{
  struct
  {
    int __lock;
    unsigned int __futex;
    unsigned long long int __total_seq;
    unsigned long long int __wakeup_seq;
    unsigned long long int __woken_seq;
    void *__mutex;
    unsigned int __nwaiters;
    unsigned int __broadcast_seq;
  } __data;
  char __size[__SIZEOF_PTHREAD_COND_T];
  __extension__ long long int __align;
} pthread_cond_t;
]]

ffi.cdef[[
/* Mutex. */
struct ovs_mutex {
    pthread_mutex_t lock;
    const char *where;          /* NULL if and only if uninitialized. */
};
]]

--[[
/* "struct ovs_mutex" initializer. */
#ifdef PTHREAD_ERRORCHECK_MUTEX_INITIALIZER_NP
#define OVS_MUTEX_INITIALIZER { PTHREAD_ERRORCHECK_MUTEX_INITIALIZER_NP, \
                                "<unlocked>" }
#else
#define OVS_MUTEX_INITIALIZER { PTHREAD_MUTEX_INITIALIZER, "<unlocked>" }
#endif

#ifdef PTHREAD_ADAPTIVE_MUTEX_INITIALIZER_NP
#define OVS_ADAPTIVE_MUTEX_INITIALIZER                  \
    { PTHREAD_ADAPTIVE_MUTEX_INITIALIZER_NP, "<unlocked>" }
#else
#define OVS_ADAPTIVE_MUTEX_INITIALIZER OVS_MUTEX_INITIALIZER
#endif
--]]

ffi.cdef[[
/* ovs_mutex functions analogous to pthread_mutex_*() functions.
 *
 * Most of these functions abort the process with an error message on any
 * error.  ovs_mutex_trylock() is an exception: it passes through a 0 or EBUSY
 * return value to the caller and aborts on any other error. */
void ovs_mutex_init(const struct ovs_mutex *);
void ovs_mutex_init_recursive(const struct ovs_mutex *);
void ovs_mutex_init_adaptive(const struct ovs_mutex *);
void ovs_mutex_destroy(const struct ovs_mutex *);
void ovs_mutex_unlock(const struct ovs_mutex *mutex);
void ovs_mutex_lock_at(const struct ovs_mutex *mutex, const char *where);
]]

--[[
#define ovs_mutex_lock(mutex) \
        ovs_mutex_lock_at(mutex, OVS_SOURCE_LOCATOR)

int ovs_mutex_trylock_at(const struct ovs_mutex *mutex, const char *where)
    OVS_TRY_LOCK(0, mutex);
#define ovs_mutex_trylock(mutex) \
        ovs_mutex_trylock_at(mutex, OVS_SOURCE_LOCATOR)
]]

ffi.cdef[[
void ovs_mutex_cond_wait(pthread_cond_t *, const struct ovs_mutex *);



struct ovsthread_once {
    bool done;               /* Non-atomic, false negatives possible. */
    struct ovs_mutex mutex;
};
]]

--[[
#define OVSTHREAD_ONCE_INITIALIZER              \
    {                                           \
        false,                                  \
        OVS_MUTEX_INITIALIZER,                  \
    }
--]]

--static inline bool ovsthread_once_start(struct ovsthread_once *once)
--    OVS_TRY_LOCK(true, once->mutex);
ffi.cdef[[
void ovsthread_once_done(struct ovsthread_once *once);
bool ovsthread_once_start__(struct ovsthread_once *once);
]]

--[[
/* Returns true if this is the first call to ovsthread_once_start() for
 * 'once'.  In this case, the caller should perform whatever initialization
 * actions it needs to do, then call ovsthread_once_done() for 'once'.
 *
 * Returns false if this is not the first call to ovsthread_once_start() for
 * 'once'.  In this case, the call will not return until after
 * ovsthread_once_done() has been called. */
--]]
--[[
static inline bool
ovsthread_once_start(struct ovsthread_once *once)
{
    /* We may be reading 'done' at the same time as the first thread
     * is writing on it, or we can be using a stale copy of it.  The
     * worst that can happen is that we call ovsthread_once_start__()
     * once when strictly not necessary. */
    return OVS_UNLIKELY(!once->done && ovsthread_once_start__(once));
}
--]]

local Lib_thread = ffi.load("openvswitch")

local exports = {
    
}

return exports;
