--[[
Original ffi code lifted from luajit.io: 
https://github.com/kingluo/luajit.io

With the following copyright

Copyright (c) 2015, Jinhua Luo (罗锦华) home_king@163.com
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

---]]

local ffi = require("ffi")

ffi.cdef[[
void OPENSSL_config(const char *config_name);
void OPENSSL_add_all_algorithms_noconf(void);
int SSL_library_init(void);
void *SSLv23_method(void);
void SSL_load_error_strings(void );
void *SSL_CTX_new(const void *method);
void SSL_CTX_free(void *ctx);
void SSL_set_read_ahead(void *s, int yes);
long SSL_CTX_ctrl(void *ctx,int cmd, long larg, void *parg);
int SSL_CTX_use_PrivateKey_file(void *ctx, const char *file, int type);
int SSL_CTX_use_certificate_file(void *ctx, const char *file, int type);
int SSL_CTX_set_cipher_list(void *,const char *str);
void *SSL_new(void *ctx);
void SSL_free(void *ssl);
int SSL_set_fd(void *ssl, int fd);
int SSL_accept(void *ssl);
int SSL_connect(void *ssl);
int SSL_read(void *ssl, void *buf, int num);
int SSL_write(void *ssl, const void *buf, int num);
void SSL_set_quiet_shutdown(void *ssl,int mode);
int SSL_shutdown(void *ssl);
unsigned long ERR_peek_error(void);
int SSL_get_error(const void *ssl, int ret);
void SSL_set_connect_state(void *ssl);
void SSL_set_accept_state(void *ssl);


]]


local Lib_ssl = ffi.load("libssl"); 
local exports = {
	-- Library reference
	Lib_ssl = Lib_ssl;

	-- Some constants
	SSL_FILETYPE_PEM = 1;
	SSL_ERROR_SSL = 1;
	SSL_ERROR_WANT_READ = 2;
	SSL_ERROR_WANT_WRITE = 3;
	SSL_ERROR_SYSCALL = 5;
	SSL_ERROR_ZERO_RETURN = 6;
	SSL_OP_NO_COMPRESSION = 0x00020000;
	SSL_MODE_RELEASE_BUFFERS = 0x00000010;
	SSL_CTRL_OPTIONS = 32;
	SSL_CTRL_MODE = 33;


	SSL_library_init = Lib_ssl.SSL_library_init;

	OPENSSL_config = Lib_ssl.OPENSSL_config;
	OPENSSL_add_all_algorithms_noconf = Lib_ssl.OPENSSL_add_all_algorithms_noconf;
	SSLv23_method = Lib_ssl.SSLv23_method;
	SSL_load_error_strings = Lib_ssl.SSL_load_error_strings;
	SSL_CTX_new = Lib_ssl.SSL_CTX_new;
	SSL_CTX_free = Lib_ssl.SSL_CTX_free;
	SSL_set_read_ahead = Lib_ssl.SSL_set_read_ahead;
	SSL_CTX_ctrl = Lib_ssl.SSL_CTX_ctrl;
	SSL_CTX_use_PrivateKey_file = Lib_ssl.SSL_CTX_use_PrivateKey_file;
	SSL_CTX_use_certificate_file = Lib_ssl.SSL_CTX_use_certificate_file;
	SSL_CTX_set_cipher_list = Lib_ssl.SSL_CTX_set_cipher_list;

	SSL_new = Lib_ssl.SSL_new;
	SSL_free = Lib_ssl.SSL_free;
	SSL_set_fd = Lib_ssl.SSL_set_fd;
	SSL_accept = Lib_ssl.SSL_accept;
	SSL_connect = Lib_ssl.SSL_connect;
	SSL_read = Lib_ssl.SSL_read;
	SSL_write = Lib_ssl.SSL_write;
	SSL_set_quiet_shutdown = Lib_ssl.SSL_set_quiet_shutdown;
	SSL_shutdown = Lib_ssl.SSL_shutdown;
	ERR_peek_error = Lib_ssl.ERR_peek_error;
	SSL_get_error = Lib_ssl.SSL_get_error;
	SSL_set_connect_state = Lib_ssl.SSL_set_connect_state;
	SSL_set_accept_state = Lib_ssl.SSL_set_accept_state;
}

return exports;
