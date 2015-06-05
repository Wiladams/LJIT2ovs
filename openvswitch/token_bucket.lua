local ffi = require("ffi")

ffi.cdef[[
struct token_bucket {
    /* Configuration settings. */
    unsigned int rate;          /* Tokens added per millisecond. */
    unsigned int burst;         /* Max cumulative tokens credit. */

    /* Current status. */
    unsigned int tokens;        /* Current number of tokens. */
    long long int last_fill;    /* Last time tokens added. */
};
]]

--#define TOKEN_BUCKET_INIT(RATE, BURST) { RATE, BURST, 0, LLONG_MIN }

ffi.cdef[[
void token_bucket_init(struct token_bucket *,
                       unsigned int rate, unsigned int burst);
void token_bucket_set(struct token_bucket *,
                       unsigned int rate, unsigned int burst);
bool token_bucket_withdraw(struct token_bucket *, unsigned int n);
void token_bucket_wait(struct token_bucket *, unsigned int n);
]]

local Lib_token_bucket = ffi.load("openvswitch")

local exports = {
	Lib_token_bucket = Lib_token_bucket;

	token_bucket_init = Lib_token_bucket.token_bucket_init;
	token_bucket_set = Lib_token_bucket.token_bucket_set;
	token_bucket_withdraw = Lib_token_bucket.token_bucket_withdraw;
	token_bucket_wait = Lib_token_bucket.token_bucket_wait;
}

return exports
