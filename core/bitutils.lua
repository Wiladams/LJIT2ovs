
local INT8_MAX    = 0x7f;
local INT8_MIN    = (-INT8_MAX - 1);
local UINT8_MAX   = 0xff;

local INT16_MAX   = 0x7fff;
local INT16_MIN   = (-INT16_MAX - 1);
local UINT16_MAX  = 0xffff;

local INT32_MAX   = 0x7fffffff;
local INT32_MIN   = (-INT32_MAX - 1);
local UINT32_MAX  = 0xffffffff;

local INT64_MAX   = 0x7fffffffffffffffLL;
local INT64_MIN   = (-INT64_MAX - 1LL);
local UINT64_MAX  = 0xffffffffffffffffULL;



local function minbytes(value)
    local bytes;
    
    if (value <= UINT32_MAX) then
        if (value < 16777216) then
            if (value <= UINT16_MAX) then
                if (value <= UINT8_MAX) then 
                    bytes = 1;
                else 
                    bytes = 2;
                end
            else 
                bytes = 3;
            end
        else 
            bytes = 4;
        end
    
    elseif (value <= UINT64_MAX) then 
        if (value < 72057594000000000ULL) then 
            if (value < 281474976710656ULL) then
                if (value < 1099511627776ULL) then
                    bytes = 5;
                else 
                    bytes = 6;
                end
            else 
                bytes = 7;
            end
        else 
            bytes = 8;
        end
    end

    return bytes;
end

return {
    minbytes = minbytes;
}
