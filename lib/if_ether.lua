local ffi = require("ffi")

ffi.cdef[[
/*
 *	IEEE 802.3 Ethernet magic constants.  The frame sizes omit the preamble
 *	and FCS/CRC (frame check sequence).
 */

static const int ETH_ALEN	= 6;		/* Octets in one ethernet addr	 */
static const int ETH_HLEN	= 14;		/* Total octets in header.	 */
static const int ETH_ZLEN	= 60;		/* Min. octets in frame sans FCS */
static const int ETH_DATA_LEN	= 1500;		/* Max. octets in payload	 */
static const int ETH_FRAME_LEN	= 1514;		/* Max. octets in frame sans FCS */
static const int ETH_FCS_LEN	= 4;		/* Octets in the FCS		 */
]]
