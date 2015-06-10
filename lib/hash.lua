local ffi = require("ffi")
local bit = require("bit")
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

require ("lib.util")





ffi.cdef[[
uint32_t hash_bytes(const void *, size_t n_bytes, uint32_t basis);
/* The hash input must be a word larger than 128 bits. */
void hash_bytes128(const void *_, size_t n_bytes, uint32_t basis,
                   ovs_u128 *out);
]]

static inline uint32_t hash_int(uint32_t x, uint32_t basis);
static inline uint32_t hash_2words(uint32_t, uint32_t);
static inline uint32_t hash_uint64(const uint64_t);
static inline uint32_t hash_uint64_basis(const uint64_t x, const uint32_t basis);
static inline uint32_t hash_boolean(bool x, uint32_t basis);
static inline uint32_t hash_pointer(const void *, uint32_t basis);
static inline uint32_t hash_string(const char *, uint32_t basis);


ffi.cdef[[
uint32_t hash_3words(uint32_t, uint32_t, uint32_t);

uint32_t hash_double(double, uint32_t basis);
]]

local function hash_rot(x, k)
    return bor(lshift(x, k), rshift(x, (32 - k)));
end

--[[
/* Murmurhash by Austin Appleby,
 * from http://code.google.com/p/smhasher/source/browse/trunk/MurmurHash3.cpp.
 *
 * The upstream license there says:
 *
 * // MurmurHash3 was written by Austin Appleby, and is placed in the public
 * // domain. The author hereby disclaims copyright to this source code.
 *
 * See hash_words() for sample usage. */
--]]

local function mhash_add__(hash, data)
    data = data * 0xcc9e2d51;
    data = hash_rot(data, 15);
    data = data * 0x1b873593;

    return bxor(hash, data);
end

local function mhash_add(hash, data)
    hash = mhash_add__(hash, data);
    hash = hash_rot(hash, 13);
    return hash * 5 + 0xe6546b64;
end

local function mhash_finish(hash)
    hash ^= rshift(hash, 16);
    hash = hash * 0x85ebca6b;
    hash ^= rshift(hash, 13);
    hash = hash * 0xc2b2ae35;
    hash ^= rshift(hash, 16);

    return hash;
end


-- Mhash-based implementation. */

--static inline uint32_t 
local function hash_add(uint32_t hash, uint32_t data)
    return mhash_add(hash, data);
end

-- static inline uint32_t 
local function hash_add64(uint32_t hash, uint64_t data)
    return hash_add(hash_add(hash, data), data >> 32);
end

--static inline uint32_t 
local function hash_finish(uint32_t hash, uint32_t final)

    return mhash_finish(hash ^ final);
end

--[[
/* Returns the hash of the 'n' 32-bit words at 'p', starting from 'basis'.
 * 'p' must be properly aligned.
 *
 * This is inlined for the compiler to have access to the 'n_words', which
 * in many cases is a constant. */
--]]
--static inline uint32_t
hash_words_inline(const uint32_t p[], size_t n_words, uint32_t basis)

    uint32_t hash;
    size_t i;

    hash = basis;
    for (i = 0; i < n_words; i++) {
        hash = hash_add(hash, p[i]);
    }
    return hash_finish(hash, n_words * 4);
end

--static inline uint32_t
local function hash_words64_inline(const uint64_t p[], size_t n_words, uint32_t basis)

    uint32_t hash;
    size_t i;

    hash = basis;
    for (i = 0; i < n_words; i++) do
        hash = hash_add64(hash, p[i]);
    end

    return hash_finish(hash, n_words * 8);
end

static inline uint32_t hash_pointer(const void *p, uint32_t basis)
--[[
    /* Often pointers are hashed simply by casting to integer type, but that
     * has pitfalls since the lower bits of a pointer are often all 0 for
     * alignment reasons.  It's hard to guess where the entropy really is, so
     * we give up here and just use a high-quality hash function.
     *
     * The double cast suppresses a warning on 64-bit systems about casting to
     * an integer to different size.  That's OK in this case, since most of the
     * entropy in the pointer is almost certainly in the lower 32 bits. */
--]]
    return hash_int((uint32_t) (uintptr_t) p, basis);
end

-- static inline uint32_t 
local function hash_2words(x, y)
    return hash_finish(hash_add(hash_add(x, 0), y), 8);
end

-- static inline uint32_t 
local function hash_uint64_basis(const uint64_t x, const uint32_t basis)
    return hash_finish(hash_add64(basis, x), 8);
end

--static inline uint32_t 
local function hash_uint64(x)
    return hash_uint64_basis(x, 0);
end


ffi.cdef[[
uint32_t hash_words__(const uint32_t p[], size_t n_words, uint32_t basis);
uint32_t hash_words64__(const uint64_t p[], size_t n_words, uint32_t basis);
]]

--/* Inline the larger hash functions only when 'n_words' is known to be
-- * compile-time constant. */

--static inline uint32_t
local function hash_words(const uint32_t p[], size_t n_words, uint32_t basis)

    return hash_words__(p, n_words, basis);
end

--static inline uint32_t
local function hash_words64(const uint64_t p[], size_t n_words, uint32_t basis)

    return hash_words64__(p, n_words, basis);
end


local function hash_string(const char *s, uint32_t basis)
    return hash_bytes(s, strlen(s), basis);
end

local function hash_int(uint32_t x, uint32_t basis)
    return hash_2words(x, basis);
end

--/* An attempt at a useful 1-bit hash function.  Has not been analyzed for
-- * quality. */
local function hash_boolean(bool x, uint32_t basis)

    local P0 = 0xc2b73583;   -- This is hash_int(1, 0).
    local P1 = 0xe90f1258;   -- This is hash_int(2, 0).
    if x then
        return P0 ^ hash_rot(basis, 1);
    end

    return P1 ^ hash_rot(basis, 1);
end

