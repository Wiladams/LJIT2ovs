local ffi = require("ffi")

require("ovs_list")
require("ovs_types")
require("openflow")



ffi.cdef[[
struct ofpbuf;
struct pvconn;
struct pvconn_class;
struct vconn;
struct vconn_class;

void vconn_usage(bool active, bool passive, bool bootstrap);

/* Active vconns: virtual connections to OpenFlow devices. */
int vconn_verify_name(const char *name);
int vconn_open(const char *name, uint32_t allowed_versions, uint8_t dscp,
               struct vconn **vconnp);
void vconn_close(struct vconn *);
const char *vconn_get_name(const struct vconn *);

uint32_t vconn_get_allowed_versions(const struct vconn *vconn);
void vconn_set_allowed_versions(struct vconn *vconn,
                                uint32_t allowed_versions);
int vconn_get_version(const struct vconn *);
void vconn_set_recv_any_version(struct vconn *);

int vconn_connect(struct vconn *);
int vconn_recv(struct vconn *, struct ofpbuf **);
int vconn_send(struct vconn *, struct ofpbuf *);
int vconn_recv_xid(struct vconn *, ovs_be32 xid, struct ofpbuf **);
int vconn_transact(struct vconn *, struct ofpbuf *, struct ofpbuf **);
int vconn_transact_noreply(struct vconn *, struct ofpbuf *, struct ofpbuf **);
int vconn_transact_multiple_noreply(struct vconn *, struct ovs_list *requests,
                                    struct ofpbuf **replyp);

void vconn_run(struct vconn *);
void vconn_run_wait(struct vconn *);

int vconn_get_status(const struct vconn *);

int vconn_open_block(const char *name, uint32_t allowed_versions, uint8_t dscp,
                     struct vconn **);
int vconn_connect_block(struct vconn *);
int vconn_send_block(struct vconn *, struct ofpbuf *);
int vconn_recv_block(struct vconn *, struct ofpbuf **);

enum vconn_wait_type {
    WAIT_CONNECT,
    WAIT_RECV,
    WAIT_SEND
};
void vconn_wait(struct vconn *, enum vconn_wait_type);
void vconn_connect_wait(struct vconn *);
void vconn_recv_wait(struct vconn *);
void vconn_send_wait(struct vconn *);

/* Passive vconns: virtual listeners for incoming OpenFlow connections. */
int pvconn_verify_name(const char *name);
int pvconn_open(const char *name, uint32_t allowed_versions, uint8_t dscp,
                struct pvconn **pvconnp);
const char *pvconn_get_name(const struct pvconn *);
void pvconn_close(struct pvconn *);
int pvconn_accept(struct pvconn *, struct vconn **);
void pvconn_wait(struct pvconn *);
]]
