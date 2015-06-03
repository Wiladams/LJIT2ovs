local ffi = require("ffi")
local bit = require("bit")
local band, bor, rshift = bit.band, bit.bor, bit.rshift;

local bitutils = require("bitutils")

--[[
#include <arpa/inet.h>

#include "compiler.h"
#include "openvswitch/types.h"
#include "openvswitch/util.h"
--]]

local Lib_util = ffi.load("openvswitch")

ffi.cdef[[
typedef uint64_t uintmax_t;
]]

--[[
#ifndef va_copy
#ifdef __va_copy
#define va_copy __va_copy
#else
#define va_copy(dst, src) ((dst) = (src))
#endif
#endif
--]]

--[[
#ifdef __CHECKER__
#define BUILD_ASSERT(EXPR) ((void) 0)
#define BUILD_ASSERT_DECL(EXPR) extern int (*build_assert(void))[1]
#elif !defined(__cplusplus)
/* Build-time assertion building block. */
#define BUILD_ASSERT__(EXPR) \
        sizeof(struct { unsigned int build_assert_failed : (EXPR) ? 1 : -1; })

/* Build-time assertion for use in a statement context. */
#define BUILD_ASSERT(EXPR) (void) BUILD_ASSERT__(EXPR)

/* Build-time assertion for use in a declaration context. */
#define BUILD_ASSERT_DECL(EXPR) \
        extern int (*build_assert(void))[BUILD_ASSERT__(EXPR)]
#else /* __cplusplus */
#include <boost/static_assert.hpp>
#define BUILD_ASSERT BOOST_STATIC_ASSERT
#define BUILD_ASSERT_DECL BOOST_STATIC_ASSERT
#endif /* __cplusplus */
--]]

--[[
#ifdef __GNUC__
#define BUILD_ASSERT_GCCONLY(EXPR) BUILD_ASSERT(EXPR)
#define BUILD_ASSERT_DECL_GCCONLY(EXPR) BUILD_ASSERT_DECL(EXPR)
#else
#define BUILD_ASSERT_GCCONLY(EXPR) ((void) 0)
#define BUILD_ASSERT_DECL_GCCONLY(EXPR) ((void) 0)
#endif

/* Like the standard assert macro, except writes the failure message to the
 * log. */
#ifndef NDEBUG
#define ovs_assert(CONDITION)                                           \
    if (!OVS_LIKELY(CONDITION)) {                                       \
        ovs_assert_failure(OVS_SOURCE_LOCATOR, __func__, #CONDITION);       \
    }
#else
#define ovs_assert(CONDITION) ((void) (CONDITION))
#endif
--]]

ffi.cdef[[
void ovs_assert_failure(const char *, const char *, const char *);
]]

--[[
/* Casts 'pointer' to 'type' and issues a compiler warning if the cast changes
 * anything other than an outermost "const" or "volatile" qualifier.
 *
 * The cast to int is present only to suppress an "expression using sizeof
 * bool" warning from "sparse" (see
 * http://permalink.gmane.org/gmane.comp.parsers.sparse/2967). */
#define CONST_CAST(TYPE, POINTER)                               \
    ((void) sizeof ((int) ((POINTER) == (TYPE) (POINTER))),     \
     (TYPE) (POINTER))
--]]

--extern char *program_name;

local function __ARRAY_SIZE_NOCHECK(ARRAY) 
    return ffi.sizeof(ARRAY) / ffi.sizeof(ARRAY[0])
end

--[[
#ifdef __GNUC__
/* return 0 for array types, 1 otherwise */
#define __ARRAY_CHECK(ARRAY) 					\
    !__builtin_types_compatible_p(typeof(ARRAY), typeof(&ARRAY[0]))

/* compile-time fail if not array */
#define __ARRAY_FAIL(ARRAY) (sizeof(char[-2*!__ARRAY_CHECK(ARRAY)]))
#define __ARRAY_SIZE(ARRAY)					\
    __builtin_choose_expr(__ARRAY_CHECK(ARRAY),			\
        __ARRAY_SIZE_NOCHECK(ARRAY), __ARRAY_FAIL(ARRAY))
#else
--]]
local function __ARRAY_SIZE(ARRAY) 
    return __ARRAY_SIZE_NOCHECK(ARRAY);
end

-- Returns the number of elements in ARRAY. */
local function ARRAY_SIZE(ARRAY) 
    return __ARRAY_SIZE(ARRAY);
end

-- Returns X / Y, rounding up.  X must be nonnegative to round correctly. */
local function DIV_ROUND_UP(X, Y) 
    return (X + (Y - 1)) / Y
end

-- Returns X rounded up to the nearest multiple of Y. */
local function ROUND_UP(X, Y) 
    return DIV_ROUND_UP(X, Y) * Y
end

-- Returns the least number that, when added to X, yields a multiple of Y. */
local function PAD_SIZE(X, Y) 
    return ROUND_UP(X, Y) - X
end

-- Returns X rounded down to the nearest multiple of Y. */
local function ROUND_DOWN(X, Y) 
    return X / Y * Y
end

--/* Returns true if X is a power of 2, otherwise false. */
local function  IS_POW2(X) 
    return (X ~= 0) and band(X, (X - 1)) == 0
end

local function is_pow2(x)
    return IS_POW2(x);
end

--[[
/* Returns X rounded up to a power of 2.  X must be a constant expression. */
#define ROUND_UP_POW2(X) RUP2__(X)
#define RUP2__(X) (RUP2_1(X) + 1)
#define RUP2_1(X) (RUP2_2(X) | (RUP2_2(X) >> 16))
#define RUP2_2(X) (RUP2_3(X) | (RUP2_3(X) >> 8))
#define RUP2_3(X) (RUP2_4(X) | (RUP2_4(X) >> 4))
#define RUP2_4(X) (RUP2_5(X) | (RUP2_5(X) >> 2))
#define RUP2_5(X) (RUP2_6(X) | (RUP2_6(X) >> 1))
#define RUP2_6(X) ((X) - 1)

/* Returns X rounded down to a power of 2.  X must be a constant expression. */
#define ROUND_DOWN_POW2(X) RDP2__(X)
#define RDP2__(X) (RDP2_1(X) - (RDP2_1(X) >> 1))
#define RDP2_1(X) (RDP2_2(X) | (RDP2_2(X) >> 16))
#define RDP2_2(X) (RDP2_3(X) | (RDP2_3(X) >> 8))
#define RDP2_3(X) (RDP2_4(X) | (RDP2_4(X) >> 4))
#define RDP2_4(X) (RDP2_5(X) | (RDP2_5(X) >> 2))
#define RDP2_5(X) (      (X) | (      (X) >> 1))
--]]

--[[
--/* This system's cache line size, in bytes.
-- * Being wrong hurts performance but not correctness. */
#define CACHE_LINE_SIZE 64
BUILD_ASSERT_DECL(IS_POW2(CACHE_LINE_SIZE));

static inline void
ovs_prefetch_range(const void *start, size_t size)
{
    const char *addr = (const char *)start;
    size_t ofs;

    for (ofs = 0; ofs < size; ofs += CACHE_LINE_SIZE) {
        OVS_PREFETCH(addr + ofs);
    }
}
--]]


local function OVS_NOT_REACHED() 
    error()
end

--[[
/* Given a pointer-typed lvalue OBJECT, expands to a pointer type that may be
 * assigned to OBJECT. */
#ifdef __GNUC__
#define OVS_TYPEOF(OBJECT) typeof(OBJECT)
#else
#define OVS_TYPEOF(OBJECT) void *
#endif

/* Given OBJECT of type pointer-to-structure, expands to the offset of MEMBER
 * within an instance of the structure.
 *
 * The GCC-specific version avoids the technicality of undefined behavior if
 * OBJECT is null, invalid, or not yet initialized.  This makes some static
 * checkers (like Coverity) happier.  But the non-GCC version does not actually
 * dereference any pointer, so it would be surprising for it to cause any
 * problems in practice.
 */
#ifdef __GNUC__
#define OBJECT_OFFSETOF(OBJECT, MEMBER) offsetof(typeof(*(OBJECT)), MEMBER)
#else
#define OBJECT_OFFSETOF(OBJECT, MEMBER) \
    ((char *) &(OBJECT)->MEMBER - (char *) (OBJECT))
#endif

/* Given POINTER, the address of the given MEMBER in a STRUCT object, returns
   the STRUCT object. */
#define CONTAINER_OF(POINTER, STRUCT, MEMBER)                           \
        ((STRUCT *) (void *) ((char *) (POINTER) - offsetof (STRUCT, MEMBER)))

/* Given POINTER, the address of the given MEMBER within an object of the type
 * that that OBJECT points to, returns OBJECT as an assignment-compatible
 * pointer type (either the correct pointer type or "void *").  OBJECT must be
 * an lvalue.
 *
 * This is the same as CONTAINER_OF except that it infers the structure type
 * from the type of '*OBJECT'. */
#define OBJECT_CONTAINING(POINTER, OBJECT, MEMBER)                      \
    ((OVS_TYPEOF(OBJECT)) (void *)                                      \
     ((char *) (POINTER) - OBJECT_OFFSETOF(OBJECT, MEMBER)))

/* Given POINTER, the address of the given MEMBER within an object of the type
 * that that OBJECT points to, assigns the address of the outer object to
 * OBJECT, which must be an lvalue.
 *
 * Evaluates to (void) 0 as the result is not to be used. */
#define ASSIGN_CONTAINER(OBJECT, POINTER, MEMBER) \
    ((OBJECT) = OBJECT_CONTAINING(POINTER, OBJECT, MEMBER), (void) 0)

/* As explained in the comment above OBJECT_OFFSETOF(), non-GNUC compilers
 * like MSVC will complain about un-initialized variables if OBJECT
 * hasn't already been initialized. To prevent such warnings, INIT_CONTAINER()
 * can be used as a wrapper around ASSIGN_CONTAINER. */
#define INIT_CONTAINER(OBJECT, POINTER, MEMBER) \
    ((OBJECT) = NULL, ASSIGN_CONTAINER(OBJECT, POINTER, MEMBER))

/* Given ATTR, and TYPE, cast the ATTR to TYPE by first casting ATTR to
 * (void *). This is to suppress the alignment warning issued by clang. */
#define ALIGNED_CAST(TYPE, ATTR) ((TYPE) (void *) (ATTR))
--]]

--[[
/* Use "%"PRIuSIZE to format size_t with printf(). */
#ifdef _WIN32
#define PRIdSIZE "Id"
#define PRIiSIZE "Ii"
#define PRIoSIZE "Io"
#define PRIuSIZE "Iu"
#define PRIxSIZE "Ix"
#define PRIXSIZE "IX"
#else
#define PRIdSIZE "zd"
#define PRIiSIZE "zi"
#define PRIoSIZE "zo"
#define PRIuSIZE "zu"
#define PRIxSIZE "zx"
#define PRIXSIZE "zX"
#endif

#ifndef _WIN32
typedef uint32_t HANDLE;
#endif
--]]


--[[
local function  set_program_name(name)
    return ovs_set_program_name(name, OVS_PACKAGE_VERSION);
end
--]]

ffi.cdef[[
const char *get_subprogram_name(void);
void set_subprogram_name(const char *format, ...);

void ovs_print_version(uint8_t min_ofp, uint8_t max_ofp);
]]

ffi.cdef[[
void out_of_memory(void);
void *xmalloc(size_t);
void *xcalloc(size_t, size_t);
void *xzalloc(size_t) ;
void *xrealloc(void *, size_t);
void *xmemdup(const void *, size_t);
char *xmemdup0(const char *, size_t);
char *xstrdup(const char *);
char *xasprintf(const char *format, ...) ;
char *xvasprintf(const char *format, va_list) ;
void *x2nrealloc(void *p, size_t *n, size_t s);

void *xmalloc_cacheline(size_t);
void *xzalloc_cacheline(size_t);
void free_cacheline(void *);
]]

ffi.cdef[[
void ovs_strlcpy(char *dst, const char *src, size_t size);
void ovs_strzcpy(char *dst, const char *src, size_t size);

void ovs_abort(int err_no, const char *format, ...);
void ovs_abort_valist(int err_no, const char *format, va_list);
void ovs_fatal(int err_no, const char *format, ...);
void ovs_fatal_valist(int err_no, const char *format, va_list);
void ovs_error(int err_no, const char *format, ...);
void ovs_error_valist(int err_no, const char *format, va_list);
const char *ovs_retval_to_string(int);
const char *ovs_strerror(int);
//void ovs_hex_dump(FILE *, const void *, size_t, uintptr_t offset, bool ascii);
]]

ffi.cdef[[
bool str_to_int(const char *, int base, int *);
bool str_to_long(const char *, int base, long *);
bool str_to_llong(const char *, int base, long long *);
bool str_to_uint(const char *, int base, unsigned int *);

bool ovs_scan(const char *s, const char *format, ...) ;
bool ovs_scan_len(const char *s, int *n, const char *format, ...);

bool str_to_double(const char *, double *);

int hexit_value(int c);
uintmax_t hexits_value(const char *s, size_t n, bool *ok);
const char *english_list_delimiter(size_t index, size_t total);
char *get_cwd(void);
char *abs_file_name(const char *dir, const char *file_name);
char *follow_symlinks(const char *filename);
void ignore(bool x);
]]

if ffi.os == "Windows" then
ffi.cdef[[
char *dir_name(const char *file_name);
char *base_name(const char *file_name);
]]
end


--[[
/* Bitwise tests. */

/* Returns the number of trailing 0-bits in 'n'.  Undefined if 'n' == 0. */
#if __GNUC__ >= 4
static inline int
raw_ctz(uint64_t n)
{
    /* With GCC 4.7 on 32-bit x86, if a 32-bit integer is passed as 'n', using
     * a plain __builtin_ctzll() here always generates an out-of-line function
     * call.  The test below helps it to emit a single 'bsf' instruction. */
    return (__builtin_constant_p(n <= UINT32_MAX) && n <= UINT32_MAX
            ? __builtin_ctz(n)
            : __builtin_ctzll(n));
}


local function raw_clz64(n) 
    return bitutils.minbytes(n);    -- __builtin_clzll(n);
end
--]]

ffi.cdef[[
/* Defined in util.c. */
int raw_ctz(uint64_t n);
int raw_clz64(uint64_t n);
]]

-- Returns the number of trailing 0-bits in 'n', or 32 if 'n' is 0. */
local function ctz32(n)
    if n == 0 then 
        return 32 
    end;
    
    return Lib_util.raw_ctz(n);
end

-- Returns the number of trailing 0-bits in 'n', or 64 if 'n' is 0. */
local function ctz64(n)
    if n == 0 then
        return 64;
    end

    return Lib_util.raw_ctz(n);
end

-- Returns the number of leading 0-bits in 'n', or 32 if 'n' is 0. */
local function clz32(n)
    if n == 0 then
        return 32;
    end

    return Lib_util.raw_clz64(n) - 32;
end

-- Returns the number of leading 0-bits in 'n', or 64 if 'n' is 0. */
local function clz64(n)
    if n == 0 then
        return 64;
    end

    return Lib_util.raw_clz64(n);
end

--/* Given a word 'n', calculates floor(log_2('n')).  This is equivalent
-- * to finding the bit position of the most significant one bit in 'n'.  It is
-- * an error to call this function with 'n' == 0. */

local function log_2_floor(n)
    return 63 - Lib_util.raw_clz64(n);
end

--/* Given a word 'n', calculates ceil(log_2('n')).  It is an error to
-- * call this function with 'n' == 0. */
--[[
local function log_2_ceil(uint64_t n)
    return log_2_floor(n) + !is_pow2(n);
end
--]]

--/* unsigned int count_1bits(uint64_t x):
-- *
-- * Returns the number of 1-bits in 'x', between 0 and 64 inclusive. */
if ffi.abi("64bit") then
local UINT64_C = ffi.typeof("uint64_t");
local h55 = UINT64_C(0x5555555555555555);
local h33 = UINT64_C(0x3333333333333333);
local h0F = UINT64_C(0x0F0F0F0F0F0F0F0F);
local h01 = UINT64_C(0x0101010101010101);

local function count_1bits(x)
    -- This portable implementation is the fastest one we know of for 64
    -- bits, and about 3x faster than GCC 4.7 __builtin_popcountll(). */
    x = x - band(rshift(x, 1), h55);               -- Count of each 2 bits in-place.
    x = band(x, h33) + band(rshift(x, 2), h33);  -- Count of each 4 bits in-place.
    x = band((x + rshift(x, 4)), h0F);          -- Count of each 8 bits in-place.
    return rshift((x * h01), 56);            -- Sum of all bytes. 
end
else -- Not 64-bit. 

--[[
extern const uint8_t count_1bits_8[256];
static inline unsigned int
local function count_1bits_32__(x)

    /* This portable implementation is the fastest one we know of for 32 bits,
     * and faster than GCC __builtin_popcount(). */
    return (count_1bits_8[x & 0xff] +
            count_1bits_8[(x >> 8) & 0xff] +
            count_1bits_8[(x >> 16) & 0xff] +
            count_1bits_8[x >> 24]);
end


local function count_1bits(x)
    return count_1bits_32__(x) + count_1bits_32__rshift(x, 32);
end
--]]
end

-- Returns the rightmost 1-bit in 'x' (e.g. 01011000 => 00001000), or 0 if 'x'
-- is 0.
local function rightmost_1bit(x)
    return band(x, -x);
end

-- Returns 'x' with its rightmost 1-bit changed to a zero (e.g. 01011000 =>
-- 01010000), or 0 if 'x' is 0. */

local function zero_rightmost_1bit(x)

    return band(x, (x - 1));
end

--[[
/* Returns the index of the rightmost 1-bit in 'x' (e.g. 01011000 => 3), or 32
 * if 'x' is 0.
 *
 * Unlike the other functions for rightmost 1-bits, this function only works
 * with 32-bit integers. */
static inline int
rightmost_1bit_idx(uint32_t x)
{
    return ctz32(x);
}

/* Returns the index of the leftmost 1-bit in 'x' (e.g. 01011000 => 6), or 32
 * if 'x' is 0.
 *
 * This function only works with 32-bit integers. */
static inline uint32_t
leftmost_1bit_idx(uint32_t x)
{
    return x ? log_2_floor(x) : 32;
}

/* Return a ovs_be32 prefix in network byte order with 'plen' highest bits set.
 * Shift with 32 is undefined behavior, but we rather use 64-bit shift than
 * compare. */
static inline ovs_be32 be32_prefix_mask(int plen)
{
    return htonl((uint64_t)UINT32_MAX << (32 - plen));
}
--]]

ffi.cdef[[
bool is_all_zeros(const void *, size_t);
bool is_all_ones(const void *, size_t);
void bitwise_copy(const void *src, unsigned int src_len, unsigned int src_ofs,
                  void *dst, unsigned int dst_len, unsigned int dst_ofs,
                  unsigned int n_bits);
void bitwise_zero(void *dst_, unsigned int dst_len, unsigned dst_ofs,
                  unsigned int n_bits);
void bitwise_one(void *dst_, unsigned int dst_len, unsigned dst_ofs,
                 unsigned int n_bits);
bool bitwise_is_all_zeros(const void *, unsigned int len, unsigned int ofs,
                          unsigned int n_bits);
unsigned int bitwise_scan(const void *, unsigned int len,
                          bool target, unsigned int start, unsigned int end);
void bitwise_put(uint64_t value,
                 void *dst, unsigned int dst_len, unsigned int dst_ofs,
                 unsigned int n_bits);
uint64_t bitwise_get(const void *src, unsigned int src_len,
                     unsigned int src_ofs, unsigned int n_bits);

void xsleep(unsigned int seconds);
]]

if ffi.os == "Windows" then
ffi.cdef[[
char *ovs_format_message(int error);
char *ovs_lasterror_to_string(void);
int ftruncate(int fd, off_t length);
]]
end

local exports = {
    ovs_abort = Lib_util.ovs_abort;
    ovs_fatal = Lib_util.ovs_fatal;
}

return exports;