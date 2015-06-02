--linux.lua
--[[
	ffi routines for Linux.  
	To get full *nix support, we should use ljsyscall as that 
	has already worked out all the cross platform details.
	For now, we just want to get a minimum ste of routines
	that will work with x86_64 Linux

	As soon as this file becomes a few hundred lines, it's time
	to abandon it and switch to ljsyscall
--]]
local ffi = require("ffi")
local bit = require("bit")
local lshift, rshift, bor, band = bit.lshift, bit.rshift, bit.bor, bit.band;

ffi.cdef[[
void * malloc(const size_t size);
void free(void *);
]]

ffi.cdef[[
typedef int32_t       clockid_t;
typedef long          time_t;

struct timespec {
  time_t tv_sec;
  long   tv_nsec;
};

int clock_getres(clockid_t clk_id, struct timespec *res);
int clock_gettime(clockid_t clk_id, struct timespec *tp);
int clock_settime(clockid_t clk_id, const struct timespec *tp);
int clock_nanosleep(clockid_t clock_id, int flags, const struct timespec *request, struct timespec *remain);

static const int CLOCK_REALTIME         = 0;
static const int CLOCK_MONOTONIC            = 1;
static const int CLOCK_PROCESS_CPUTIME_ID   = 2;
static const int CLOCK_THREAD_CPUTIME_ID    = 3;
static const int CLOCK_MONOTONIC_RAW        = 4;
static const int CLOCK_REALTIME_COARSE      = 5;
static const int CLOCK_MONOTONIC_COARSE = 6;
static const int CLOCK_BOOTTIME         = 7;
static const int CLOCK_REALTIME_ALARM       = 8;
static const int CLOCK_BOOTTIME_ALARM       = 9;
static const int CLOCK_SGI_CYCLE            = 10;   // Hardware specific 
static const int CLOCK_TAI                  = 11;

]]


ffi.cdef[[
/* Flags to be passed to epoll_create1.  */
enum
  {
    EPOLL_CLOEXEC = 02000000
  };
]]

ffi.cdef[[
typedef union epoll_data {
  void *ptr;
  int fd;
  uint32_t u32;
  uint64_t u64;
} epoll_data_t;
]]


ffi.cdef([[
struct epoll_event {
int32_t events;
epoll_data_t data;
}]]..(ffi.arch == "x64" and [[__attribute__((__packed__));]] or [[;]]))



ffi.cdef[[
int epoll_create (int __size) ;
int epoll_create1 (int __flags) ;
int epoll_ctl (int __epfd, int __op, int __fd, struct epoll_event *__event) ;
int epoll_wait (int __epfd, struct epoll_event *__events, int __maxevents, int __timeout);

//int epoll_pwait (int __epfd, struct epoll_event *__events,
//          int __maxevents, int __timeout,
//          const __sigset_t *__ss);
]]


ffi.cdef[[
typedef long ssize_t;

typedef uint32_t in_addr_t;

typedef uint16_t in_port_t;

typedef unsigned short int sa_family_t;
typedef unsigned int socklen_t;

]]

ffi.cdef[[
struct in_addr {
    in_addr_t       s_addr;
};

struct in6_addr {
  unsigned char  s6_addr[16];
};
]]

ffi.cdef[[
/* Structure describing a generic socket address.  */
struct sockaddr {
  sa_family_t   sa_family;
  char          sa_data[14];
};
]]

ffi.cdef[[
struct sockaddr_in {
  sa_family_t     sin_family;
  in_port_t       sin_port;
  struct in_addr  sin_addr;
    unsigned char sin_zero[sizeof (struct sockaddr) -
      (sizeof (unsigned short int)) -
      sizeof (in_port_t) -
      sizeof (struct in_addr)];
};
]]


local sockaddr_in = ffi.typeof("struct sockaddr_in");
local sockaddr_in_mt = {
  __new = function(ct, address, port, family)
      family = family or exports.AF_INET;

      local sa = ffi.new(ct)
      sa.sin_family = family;
      sa.sin_port = exports.htons(port)
      if type(address) == "number" then
        addr.sin_addr.s_addr = address;
      elseif type(address) == "string" then
        local inp = ffi.new("struct in_addr")
        local ret = ffi.C.inet_aton (address, inp);
        sa.sin_addr.s_addr = inp.s_addr;
      end

      return sa;
  end;

  __index = {
    setPort = function(self, port)
      self.sin_port = exports.htons(port);
      return self;
    end,
  },

}
ffi.metatype(sockaddr_in, sockaddr_in_mt);

ffi.cdef[[
struct sockaddr_in6 {
  uint8_t         sin6_len;
  sa_family_t     sin6_family;
  in_port_t       sin6_port;
  uint32_t        sin6_flowinfo;
  struct in6_addr sin6_addr;
  uint32_t        sin6_scope_id;
};

struct sockaddr_un
{
    sa_family_t sun_family;
    char sun_path[108];
};

struct sockaddr_storage {
//  uint8_t       ss_len;
  sa_family_t   ss_family;
  char          __ss_pad1[6];
  int64_t       __ss_align;
  char          __ss_pad2[128 - 2 - 8 - 6];
};



/* Structure used to manipulate the SO_LINGER option.  */
struct linger
  {
    int l_onoff;    /* Nonzero to linger on close.  */
    int l_linger;   /* Time to linger.  */
  };

struct ethhdr {
  unsigned char   h_dest[6];
  unsigned char   h_source[6];
  unsigned short  h_proto; /* __be16 */
} __attribute__((packed));

struct udphdr {
  uint16_t source;
  uint16_t dest;
  uint16_t len;
  uint16_t check;
};

]]

ffi.cdef[[
int close(int fd);
int fcntl (int __fd, int __cmd, ...);
int ioctl (int __fd, unsigned long int __request, ...);

ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
]]

ffi.cdef[[
int inet_aton (__const char *__cp, struct in_addr *__inp);
char *inet_ntoa (struct in_addr __in);
]]



ffi.cdef[[
int socket(int domain, int type, int protocol);
int socketpair(int domain, int type, int protocol, int sv[2]);
ssize_t recv(int sockfd, void *buf, size_t len, int flags);
ssize_t send(int sockfd, const void *buf, size_t len, int flags);
ssize_t sendto(int sockfd, const void *buf, size_t len, int flags, const struct sockaddr *dest_addr, socklen_t addrlen);
ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags, struct sockaddr *src_addr, socklen_t *addrlen);
ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags);
ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags);
int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen);
int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
int listen(int sockfd, int backlog);
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
int accept4(int sockfd, void *addr, socklen_t *addrlen, int flags);
int getsockname(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
int getpeername(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
int shutdown(int sockfd, int how);
int sendmmsg(int sockfd, struct mmsghdr *msgvec, unsigned int vlen, unsigned int flags);
int recvmmsg(int sockfd, struct mmsghdr *msgvec, unsigned int vlen, unsigned int flags, struct timespec *timeout);
]]



ffi.cdef[[
struct addrinfo {
  int     ai_flags;          // AI_PASSIVE, AI_CANONNAME, ...
  int     ai_family;         // AF_xxx
  int     ai_socktype;       // SOCK_xxx
  int     ai_protocol;       // 0 (auto) or IPPROTO_TCP, IPPROTO_UDP 

  socklen_t  ai_addrlen;     // length of ai_addr
  struct sockaddr  *ai_addr; // binary address
  char   *ai_canonname;      // canonical name for nodename
  struct addrinfo  *ai_next; // next structure in linked list
};

int getaddrinfo(const char *nodename, const char *servname,
                const struct addrinfo *hints, struct addrinfo **res);

void freeaddrinfo(struct addrinfo *ai);
]]


local exports  = {
    -- defined metatypes
    sockaddr_in = sockaddr_in;

    -- various values for networking
FIONBIO = 0x5421;

INADDR_ANY             = 0x00000000;
INADDR_LOOPBACK        = 0x7f000001;
INADDR_BROADCAST       = 0xffffffff;
INADDR_NONE            = 0xffffffff;

INET_ADDRSTRLEN         = 16;
INET6_ADDRSTRLEN        = 46;

-- Socket Types
SOCK_STREAM     = 1;    -- stream socket
SOCK_DGRAM      = 2;    -- datagram socket
SOCK_RAW        = 3;    -- raw-protocol interface
SOCK_RDM        = 4;    -- reliably-delivered message
SOCK_SEQPACKET  = 5;    -- sequenced packet stream


-- Address families
AF_UNSPEC       = 0;          -- unspecified */
AF_LOCAL        = 1;
AF_UNIX         = 1;            -- local to host (pipes, portals) */
AF_INET         = 2;            -- internetwork: UDP, TCP, etc. */
AF_IMPLINK      = 3;         -- arpanet imp addresses */
AF_PUP          = 4;            -- pup protocols: e.g. BSP */
AF_CHAOS        = 5;           -- mit CHAOS protocols */
AF_IPX          = 6;             -- IPX and SPX */
AF_NS           = 6;              -- XEROX NS protocols */
AF_ISO          = 7;             -- ISO protocols */
AF_OSI          = 7;        -- OSI is ISO */
AF_ECMA         = 8;            -- european computer manufacturers */
AF_DATAKIT      = 9;         -- datakit protocols */
AF_CCITT        = 10;          -- CCITT protocols, X.25 etc */
AF_SNA          = 11;           -- IBM SNA */
AF_DECnet       = 12;         -- DECnet */
AF_DLI          = 13;            -- Direct data link interface */
AF_LAT          = 14;            -- LAT */
AF_HYLINK       = 15;         -- NSC Hyperchannel */
AF_APPLETALK    = 16;      -- AppleTalk */
AF_NETBIOS      = 17;        -- NetBios-style addresses */
AF_VOICEVIEW    = 18;     -- VoiceView */
AF_FIREFOX      = 19;        -- FireFox */
AF_UNKNOWN1     = 20;       -- Somebody is using this! */
AF_BAN          = 21;            -- Banyan */
AF_INET6        = 23;              -- Internetwork Version 6
AF_SIP          = 24;
AF_IRDA         = 26;              -- IrDA
AF_NETDES       = 28;       -- Network Designers OSI & gateway
AF_INET6        = 28;


AF_TCNPROCESS   = 29;
AF_TCNMESSAGE   = 30;
AF_ICLFXBM      = 31;

AF_BTH  = 32;              -- Bluetooth RFCOMM/L2CAP protocols
AF_LINK = 33;
AF_ARP  = 35;
AF_BLUETOOTH    = 36;
AF_MAX  = 37;

--
-- Protocols
--

IPPROTO_IP          = 0;        -- dummy for IP
IPPROTO_ICMP        = 1;        -- control message protocol
IPPROTO_IGMP        = 2;        -- group management protocol
IPPROTO_GGP         = 3;        -- gateway^2 (deprecated)
IPPROTO_TCP         = 6;        -- tcp
IPPROTO_PUP         = 12;       -- pup
IPPROTO_UDP         = 17;       -- user datagram protocol
IPPROTO_IDP         = 22;       -- xns idp
IPPROTO_RDP         = 27;
IPPROTO_IPV6        = 41;       -- IPv6 header
IPPROTO_ROUTING     = 43;       -- IPv6 Routing header
IPPROTO_FRAGMENT    = 44;       -- IPv6 fragmentation header
IPPROTO_ESP         = 50;       -- encapsulating security payload
IPPROTO_AH          = 51;       -- authentication header
IPPROTO_ICMPV6      = 58;       -- ICMPv6
IPPROTO_NONE        = 59;       -- IPv6 no next header
IPPROTO_DSTOPTS     = 60;       -- IPv6 Destination options
IPPROTO_ND          = 77;       -- UNOFFICIAL net disk proto
IPPROTO_ICLFXBM     = 78;
IPPROTO_PIM         = 103;
IPPROTO_PGM         = 113;
--IPPROTO_RM          = IPPROTO_PGM;
IPPROTO_L2TP        = 115;
IPPROTO_SCTP        = 132;


IPPROTO_RAW          =   255;             -- raw IP packet
IPPROTO_MAX          =   256;

-- Possible values for `ai_flags' field in `addrinfo' structure.
AI_PASSIVE              = 0x0001;
AI_CANONNAME            = 0x0002;
AI_NUMERICHOST          = 0x0004;
AI_V4MAPPED             = 0x0008;
AI_ALL                  = 0x0010;
AI_ADDRCONFIG           = 0x0020;
AI_IDN                  = 0x0040;
AI_CANONIDN             = 0x0080;
AI_IDN_ALLOW_UNASSIGNED = 0x0100;
AI_IDN_USE_STD3_ASCII_RULES = 0x0200;
AI_NUMERICSERV          = 0x0400;
}



if ffi.abi("be") then -- nothing to do
    function exports.htonl(b) return b end
    function exports.htons(b) return b end
else
    function exports.htonl(b) return bit.bswap(b) end
    function exports.htons(b) return bit.rshift(bit.bswap(b), 16) end
end
exports.ntohl = exports.htonl -- reverse is the same
exports.ntohs = exports.htons -- reverse is the same


-- Socket level values.
-- To select the IP level.
exports.SOL_IP  = 0;

-- from /usr/include/asm-generic/socket.h
-- For setsockopt(2) 
exports.SOL_SOCKET  = 1;

exports.SO_DEBUG  =1
exports.SO_REUSEADDR  =2
exports.SO_TYPE   =3
exports.SO_ERROR  =4
exports.SO_DONTROUTE  =5
exports.SO_BROADCAST  =6
exports.SO_SNDBUF =7
exports.SO_RCVBUF =8
exports.SO_SNDBUFFORCE  =32
exports.SO_RCVBUFFORCE  =33
exports.SO_KEEPALIVE  =9
exports.SO_OOBINLINE  =10
exports.SO_NO_CHECK =11
exports.SO_PRIORITY =12
exports.SO_LINGER =13
exports.SO_BSDCOMPAT  =14
exports.SO_REUSEPORT  =15
exports.SO_PASSCRED =16
exports.SO_PEERCRED =17
exports.SO_RCVLOWAT =18
exports.SO_SNDLOWAT =19
exports.SO_RCVTIMEO =20
exports.SO_SNDTIMEO =21

exports.SOL_IPV6    = 41;
exports.SOL_ICMPV6  = 58;

exports.SOL_RAW      = 255;
exports.SOL_DECNET  =    261;
exports.SOL_X25     =    262;
exports.SOL_PACKET  = 263;
exports.SOL_ATM      = 264; -- ATM layer (cell level).
exports.SOL_AAL      = 265; -- ATM Adaption Layer (packet level).
exports.SOL_IRDA     = 266;

-- Maximum queue length specifiable by listen.
exports.SOMAXCONN   = 128;


-- for SOL_IP Options
exports.IP_DEFAULT_MULTICAST_TTL     =   1;
exports.IP_DEFAULT_MULTICAST_LOOP    =   1;
exports.IP_MAX_MEMBERSHIPS           =   20;

-- constants should be used for the second parameter of `shutdown'.
exports.SHUT_RD = 0,  -- No more receptions.
exports.SHUT_WR,    -- No more transmissions.
exports.SHUT_RDWR   -- No more receptions or transmissions.



-- the filedesc type gives an easy place to hang things
-- related to a file descriptor.  Primarily it keeps the 
-- basic file descriptor.  
-- It also performs the async read/write operations

ffi.cdef[[
typedef struct filedesc_t {
  int fd;
} filedesc;

typedef struct async_ioevent_t {
  struct filedesc_t fdesc;
  int eventKind;
} async_ioevent;
]]

exports.IO_READ = 1;
exports.IO_WRITE = 2;
exports.IO_CONNECT = 3;

local filedesc = ffi.typeof("struct filedesc_t")
local filedesc_mt = {
    __new = function(ct, fd)
        local obj = ffi.new(ct, fd);

        return obj;
    end;

    __gc = function(self)
        if self.fd > -1 then
            self:close();
        end
    end;

    __index = {
        close = function(self)
            ffi.C.close(self.fd);
            self.fd = -1; -- make it invalid
        end,

        read = function(self, buff, bufflen)
            local bytes = tonumber(ffi.C.read(self.fd, buff, bufflen));

            if bytes > 0 then
                return bytes;
            end

            if bytes == 0 then
              return 0;
            end

            return false, ffi.errno();
        end,

        write = function(self, buff, bufflen)
            local bytes = tonumber(ffi.C.write(self.fd, buff, bufflen));

            if bytes > 0 then
                return bytes;
            end

            if bytes == 0 then
              return 0;
            end

            return false, ffi.errno();
        end,

        setNonBlocking = function(self)
            local feature_on = ffi.new("int[1]",1)
            local ret = ffi.C.ioctl(self.fd, exports.FIONBIO, feature_on)
            return ret == 0;
        end,

    };
}
ffi.metatype(filedesc, filedesc_mt);
exports.filedesc = filedesc;


local timespec = ffi.typeof("struct timespec")
local timespec_mt = {
	__add = function(lhs, rhs)
		local newspec = timespec(lhs.tv_sec+rhs.tv_sec, lhs.tv_nsec+rhs.tv_nsec);
		return newspec;
	end;

	__sub = function(lhs, rhs)
		local newspec = timespec(lhs.tv_sec-rhs.tv_sec, lhs.tv_nsec-rhs.tv_nsec);
		return newspec;
	end;	

	__tostring = function(self)
		return string.format("%d.%d", tonumber(self.tv_sec), tonumber(self.tv_nsec));
	end;

	__index = {
		gettime = function(self, clockid)
			clockid = clockid or ffi.C.CLOCK_REALTIME;
			local res = ffi.C.clock_gettime(clockid, self)
			return res;
		end;
		
		getresolution = function(self, clockid)
			clockid = clockid or ffi.C.CLOCK_REALTIME;
			local res = ffi.C.clock_getres(clockid, self);
			return res;
		end;

		setFromSeconds = function(self, seconds)
			-- the seconds without fraction can become tv_sec
			local secs, frac = math.modf(seconds)
			local nsecs = frac * 1000000000;
			self.tv_sec = secs;
			self.tv_nsec = nsecs;

			return true;
		end;

		seconds = function(self)
			return tonumber(self.tv_sec) + (tonumber(self.tv_nsec) / 1000000000);	-- one billion'th of a second
		end;

	};
}
ffi.metatype(timespec, timespec_mt)
exports.timespec = timespec;

function exports.sleep(seconds, clockid, flags)
	clockid = clockid or ffi.C.CLOCK_REALTIME;
	flags = flags or 0
	local request = timespec();
	local remain = timespec();

	request:setFromSeconds(seconds);
	local res = ffi.C.clock_nanosleep(clockid, flags, request, remain);

	return remain:seconds();
end


--[[
	Things related to epoll
--]]
exports.EPOLLIN 	= 0x0001;
exports.EPOLLPRI 	= 0x0002;
exports.EPOLLOUT 	= 0x0004;
exports.EPOLLRDNORM = 0x0040;			-- SAME AS EPOLLIN
exports.EPOLLRDBAND = 0x0080;
exports.EPOLLWRNORM = 0x0100;			-- SAME AS EPOLLOUT
exports.EPOLLWRBAND = 0x0200;
exports.EPOLLMSG	= 0x0400;			-- NOT USED
exports.EPOLLERR 	= 0x0008;
exports.EPOLLHUP 	= 0x0010;
exports.EPOLLRDHUP 	= 0x2000;
exports.EPOLLWAKEUP = lshift(1,29);
exports.EPOLLONESHOT = lshift(1,30);
exports.EPOLLET 	= lshift(1,31);




-- Valid opcodes ( "op" parameter ) to issue to epoll_ctl().
exports.EPOLL_CTL_ADD =1	-- Add a file descriptor to the interface.
exports.EPOLL_CTL_DEL =2	-- Remove a file descriptor from the interface.
exports.EPOLL_CTL_MOD =3	-- Change file descriptor epoll_event structure.


ffi.cdef[[
typedef struct _epollset {
	int epfd;		// epoll file descriptor
} epollset;
]]

local epollset = ffi.typeof("epollset")
local epollset_mt = {
	__new = function(ct, epfd)
		if not epfd then
			epfd = ffi.C.epoll_create1(0);
		end

		if epfd < 0 then
			return nil;
		end

		return ffi.new(ct, epfd)
	end,

	__gc = function(self)
		-- ffi.C.close(self.epfd);
	end;

	__index = {
		add = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, exports.EPOLL_CTL_ADD, fd, event)

			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		delete = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, exports.EPOLL_CTL_DEL, fd, event)

			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		modify = function(self, fd, event)
			local ret = ffi.C.epoll_ctl(self.epfd, exports.EPOLL_CTL_MOD, fd, event)
			if ret > -1 then
				return ret;
			end

			return false, ffi.errno();
		end,

		-- struct epoll_event *__events
		wait = function(self, events, maxevents, timeout)
			maxevents = maxevents or 1
			timeout = timeout or -1

			-- gets either number of ready events
			-- or -1 indicating an error
			local ret = ffi.C.epoll_wait (self.epfd, events, maxevents, timeout);
			if ret == -1 then
				return false, ffi.errno();
			end

			return ret;
		end,
	};
}
ffi.metatype(epollset, epollset_mt);

exports.epollset = epollset;




--[[
	Linux error numbers
--]]
exports.errnos = {
    EPERM =  1;  -- Operation not permitted 
    ENOENT =  2;  -- No such file or directory 
    ESRCH =  3;  -- No such process 
    EINTR =  4;  -- Interrupted system call 
    EIO =  5;  -- I/O error 
    ENXIO =  6;  -- No such device or address 
    E2BIG =  7;  -- Argument list too long 
    ENOEXEC =  8;  -- Exec format error 
    EBADF =  9;  -- Bad file number 
    ECHILD = 10;  -- No child processes 
    EAGAIN = 11;  -- Try again 
    ENOMEM = 12;  -- Out of memory 
    EACCES = 13;  -- Permission denied 
    EFAULT = 14;  -- Bad address 
    ENOTBLK = 15;  -- Block device required 
    EBUSY = 16;  -- Device or resource busy 
    EEXIST = 17;  -- File exists 
    EXDEV = 18;  -- Cross-device link 
    ENODEV = 19;  -- No such device 
    ENOTDIR = 20;  -- Not a directory 
    EISDIR = 21;  -- Is a directory 
    EINVAL = 22;  -- Invalid argument 
    ENFILE = 23;  -- File table overflow 
    EMFILE = 24;  -- Too many open files 
    ENOTTY = 25;  -- Not a typewriter 
    ETXTBSY = 26;  -- Text file busy 
    EFBIG = 27;  -- File too large 
    ENOSPC = 28;  -- No space left on device 
    ESPIPE = 29;  -- Illegal seek 
    EROFS = 30;  -- Read-only file system 
    EMLINK = 31;  -- Too many links 
    EPIPE = 32;  -- Broken pipe 
    EDOM = 33;  -- Math argument out of domain of func 
    ERANGE = 34;  -- Math result not representable 

    EDEADLK = 35;  -- Resource deadlock would occur 
    ENAMETOOLONG = 36;  -- File name too long 
    ENOLCK = 37;  -- No record locks available 
    ENOSYS = 38;  -- Function not implemented 
    ENOTEMPTY = 39;  -- Directory not empty 
    ELOOP = 40;  -- Too many symbolic links encountered 
    EWOULDBLOCK =     EAGAIN;  -- Operation would block 
    ENOMSG = 42;  -- No message of desired type 
    EIDRM = 43;  -- Identifier removed 
    ECHRNG = 44;  -- Channel number out of range 
    EL2NSYNC = 45;  -- Level 2 not synchronized 
    EL3HLT = 46;  -- Level 3 halted 
    EL3RST = 47;  -- Level 3 reset 
    ELNRNG = 48;  -- Link number out of range 
    EUNATCH = 49;  -- Protocol driver not attached 
    ENOCSI = 50;  -- No CSI structure available 
    EL2HLT = 51;  -- Level 2 halted 
    EBADE = 52;  -- Invalid exchange 
    EBADR = 53;  -- Invalid request descriptor 
    EXFULL = 54;  -- Exchange full 
    ENOANO = 55;  -- No anode 
    EBADRQC = 56;  -- Invalid request code 
    EBADSLT = 57;  -- Invalid slot 

    EDEADLOCK  =     EDEADLK;

    EBFONT = 59;  -- Bad font file format 
    ENOSTR = 60;  -- Device not a stream 
    ENODATA = 61;  -- No data available 
    ETIME = 62;  -- Timer expired 
    ENOSR = 63;  -- Out of streams resources 
    ENONET = 64;  -- Machine is not on the network 
    ENOPKG = 65;  -- Package not installed 
    EREMOTE = 66;  -- Object is remote 
    ENOLINK = 67;  -- Link has been severed 
    EADV = 68;  -- Advertise error 
    ESRMNT = 69;  -- Srmount error 
    ECOMM = 70;  -- Communication error on send 
    EPROTO = 71;  -- Protocol error 
    EMULTIHOP = 72;  -- Multihop attempted 
    EDOTDOT = 73;  -- RFS specific error 
    EBADMSG = 74;  -- Not a data message 
    EOVERFLOW = 75;  -- Value too large for defined data type 
    ENOTUNIQ = 76;  -- Name not unique on network 
    EBADFD = 77;  -- File descriptor in bad state 
    EREMCHG = 78;  -- Remote address changed 
    ELIBACC = 79;  -- Can not access a needed shared library 
    ELIBBAD = 80;  -- Accessing a corrupted shared library 
    ELIBSCN = 81;  -- .lib section in a.out corrupted 
    ELIBMAX = 82;  -- Attempting to link in too many shared libraries 
    ELIBEXEC = 83;  -- Cannot exec a shared library directly 
    EILSEQ = 84;  -- Illegal byte sequence 
    ERESTART = 85;  -- Interrupted system call should be restarted 
    ESTRPIPE = 86;  -- Streams pipe error 
    EUSERS = 87;  -- Too many users 
    ENOTSOCK = 88;  -- Socket operation on non-socket 
    EDESTADDRREQ = 89;  -- Destination address required 
    EMSGSIZE = 90;  -- Message too long 
    EPROTOTYPE = 91;  -- Protocol wrong type for socket 
    ENOPROTOOPT = 92;  -- Protocol not available 
    EPROTONOSUPPORT = 93;  -- Protocol not supported 
    ESOCKTNOSUPPORT = 94;  -- Socket type not supported 
    EOPNOTSUPP = 95;  -- Operation not supported on transport endpoint 
    EPFNOSUPPORT = 96;  -- Protocol family not supported 
    EAFNOSUPPORT = 97;  -- Address family not supported by protocol 
    EADDRINUSE = 98;  -- Address already in use 
    EADDRNOTAVAIL = 99;  -- Cannot assign requested address 
    ENETDOWN = 100;  -- Network is down 
    ENETUNREACH = 101;  -- Network is unreachable 
    ENETRESET = 102;  -- Network dropped connection because of reset 
    ECONNABORTED = 103;  -- Software caused connection abort 
    ECONNRESET = 104;  -- Connection reset by peer 
    ENOBUFS = 105;  -- No buffer space available 
    EISCONN = 106;  -- Transport endpoint is already connected 
    ENOTCONN = 107;  -- Transport endpoint is not connected 
    ESHUTDOWN = 108;  -- Cannot send after transport endpoint shutdown 
    ETOOMANYREFS = 109;  -- Too many references: cannot splice 
    ETIMEDOUT = 110;  -- Connection timed out 
    ECONNREFUSED = 111;  -- Connection refused 
    EHOSTDOWN = 112;  -- Host is down 
    EHOSTUNREACH = 113;  -- No route to host 
    EALREADY = 114;  -- Operation already in progress 
    EINPROGRESS = 115;  -- Operation now in progress 
    ESTALE = 116;  -- Stale file handle 
    EUCLEAN = 117;  -- Structure needs cleaning 
    ENOTNAM = 118;  -- Not a XENIX named type file 
    ENAVAIL = 119;  -- No XENIX semaphores available 
    EISNAM = 120;  -- Is a named type file 
    EREMOTEIO = 121;  -- Remote I/O error 
    EDQUOT = 122;  -- Quota exceeded 

    ENOMEDIUM = 123;  -- No medium found 
    EMEDIUMTYPE = 124;  -- Wrong medium type 
    ECANCELED = 125;  -- Operation Canceled 
    ENOKEY = 126;  -- Required key not available 
    EKEYEXPIRED = 127;  -- Key has expired 
    EKEYREVOKED = 128;  -- Key has been revoked 
    EKEYREJECTED = 129;  -- Key was rejected by service 

-- for robust mutexes 
    EOWNERDEAD = 130;  -- Owner died 
    ENOTRECOVERABLE = 131;  -- State not recoverable 

    ERFKILL = 132;  -- Operation not possible due to RF-kill 

    EHWPOISON = 133;  -- Memory page has hardware error 
}

local function lookuperrno(errorNumber)
	for name, value in pairs(exports.errnos) do
		if value == errorNumber then
			return name;
		end

	end

	return "UNKNOWN ERROR: "..tostring(errorNumber);
end

exports.errnos.lookuperrno = lookuperrno;

--[[
setmetatable(exports, {
	__call = function(self, params)
		params = params or {}
		if params.exportglobal then
			for k,v in pairs(exports.errnos) do
				_G[k] = v;
			end
		end
		return self;
	end
})
--]]

setmetatable(exports, {
	__call = function(self)
		for k,v in pairs(exports) do
			_G[k] = v;
		end
	end;
})

return exports
