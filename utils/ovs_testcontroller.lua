
--[[
#include <config.h>

#include <errno.h>
#include <getopt.h>
#include <limits.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "command-line.h"
#include "compiler.h"
#include "daemon.h"
#include "fatal-signal.h"
#include "learning-switch.h"
#include "ofp-parse.h"
#include "ofp-version-opt.h"
#include "ofpbuf.h"
#include "openflow/openflow.h"
#include "poll-loop.h"
#include "rconn.h"
#include "simap.h"
#include "stream-ssl.h"
#include "timeval.h"
#include "unixctl.h"
#include "util.h"
#include "openvswitch/vconn.h"
#include "openvswitch/vlog.h"
#include "socket-util.h"
#include "ofp-util.h"
--]]

local common = require("testy.ovsdb_command_common")

local VConn = require("vconn")

local function printf(formatstr, ...)
    io.write(string.format(formatstr, ...))
end

--VLOG_DEFINE_THIS_MODULE(controller);

local MAX_SWITCHES = 16;
local MAX_LISTENERS = 16;

ffi.cdef[[
struct switch_ {
    struct lswitch *lswitch;
};
]]

--  -H, --hub: Learn the ports on which MAC addresses appear?  
local learn_macs = true;

--  -n, --noflow: Set up flows?  (If not, every packet is processed at the
-- * controller.)  
local set_up_flows = true;

--  -N, --normal: Use "NORMAL" action instead of explicit port?  
local action_normal = false;

--  -w, --wildcard: 0 to disable wildcard flow entries, an OFPFW10_* bitmask to
-- * enable specific wildcards, or UINT32_MAX to use the default wildcards.  
local wildcards = 0;

--  --max-idle: Maximum idle time, in seconds, before flows expire.  
local max_idle = 60;

--  --mute: If true, accept connections from switches but do not reply to any
-- * of their messages (for debugging fail-open mode).  
local mute = false;

--  -q, --queue: default OpenFlow queue, none if UINT32_MAX.  
local default_queue = UINT32_MAX;

--  -Q, --port-queue: map from port name to port number.  
static struct simap port_queues = SIMAP_INITIALIZER(&port_queues);

--  --with-flows: Flows to send to switch.  
static struct ofputil_flow_mod *default_flows;
static size_t n_default_flows;
static enum ofputil_protocol usable_protocols;

--  --unixctl: Name of unixctl socket, or null to use the default.  
local unixctl_path = nil;


local program_name = arg[0];

local function main(int argc, char *argv[])

    local unixctl = ffi.new("struct unixctl_server");
    local switches = ffi.new("struct switch_[?]", MAX_SWITCHES);
    local listeners = ffi.new("struct pvconn *[?]", MAX_LISTENERS);
    int i;

    ovs_cmdl_proctitle_init(argc, argv);
    parse_options(argc, argv);
 
    if (argc - optind < 1) {
        ovs_fatal(0, "at least one vconn argument required; "
                  "use --help for usage");
    }

    local n_switches = 0;
    local n_listeners = 0;

    for i = optind, argc-1 do
        const char *name = argv[i];

        local vconn, retval = VConn(name, get_allowed_ofp_versions(), DSCP_DEFAULT);

        --local retval = vconn_open(name, get_allowed_ofp_versions(), DSCP_DEFAULT,&vconn);
        if (vconn) then
            if (n_switches >= MAX_SWITCHES) then
                ovs_fatal(0, "max %d switch connections", n_switches);
            end
            new_switch(&switches[n_switches++], vconn);
            continue;
        elseif (retval == EAFNOSUPPORT) then
            struct pvconn *pvconn;
            retval = pvconn_open(name, get_allowed_ofp_versions(),
                                 DSCP_DEFAULT, &pvconn);
            if (!retval) {
                if (n_listeners >= MAX_LISTENERS) {
                    ovs_fatal(0, "max %d passive connections", n_listeners);
                }
                listeners[n_listeners++] = pvconn;
            }
        end

        if (err) then
            VLOG_ERR("%s: connect: %s", name, ovs_strerror(retval));
        end
    end

    if (n_switches == 0 and n_listeners == 0) then
        ovs_fatal(0, "no active or passive switch connections");
    end

 
    retval = unixctl_server_create(unixctl_path, &unixctl);
    if (retval) {
        halt(EXIT_FAILURE);
    }

 
    while (n_switches > 0 or n_listeners > 0) then
        -- Accept connections on listening vconns.
        for (i = 0; i < n_listeners && n_switches < MAX_SWITCHES; ) {
            struct vconn *new_vconn;

            retval = pvconn_accept(listeners[i], &new_vconn);
            if (!retval || retval == EAGAIN) {
                if (!retval) {
                    new_switch(&switches[n_switches++], new_vconn);
                }
                i++;
            } else {
                pvconn_close(listeners[i]);
                listeners[i] = listeners[--n_listeners];
            }
        }

        -- Do some switching work.  . 
        for (i = 0; i < n_switches; ) {
            struct switch_ *this = &switches[i];
            lswitch_run(this->lswitch);
            if (lswitch_is_alive(this->lswitch)) {
                i++;
            } else {
                lswitch_destroy(this->lswitch);
                switches[i] = switches[--n_switches];
            }
        }

        unixctl_server_run(unixctl);

        -- Wait for something to happen.
        if (n_switches < MAX_SWITCHES) {
            for (i = 0; i < n_listeners; i++) {
                pvconn_wait(listeners[i]);
            }
        }
        for (i = 0; i < n_switches; i++) {
            struct switch_ *sw = &switches[i];
            lswitch_wait(sw->lswitch);
        }
        unixctl_server_wait(unixctl);
        poll_block();
    end

    return 0;
end

local function new_switch(struct switch_ *sw, vconn)

    local cfg = ffi.new("struct lswitch_config");

    local rconn = rconn_create(60, 0, DSCP_DEFAULT, get_allowed_ofp_versions());
    rconn_connect_unreliably(rconn, vconn, nil);

    cfg.mode = (action_normal ? LSW_NORMAL
                : learn_macs ? LSW_LEARN
                : LSW_FLOOD);
    cfg.wildcards = wildcards;
    cfg.max_idle = set_up_flows ? max_idle : -1;
    cfg.default_flows = default_flows;
    cfg.n_default_flows = n_default_flows;
    cfg.usable_protocols = usable_protocols;
    cfg.default_queue = default_queue;
    cfg.port_queues = &port_queues;
    cfg.mute = mute;
    sw.lswitch = lswitch_create(rconn, &cfg);
end

local function add_port_queue(char *s)

    char *save_ptr = nil;
 
    local port_name = strtok_r(s, ":", &save_ptr);
    local queue_id = strtok_r(NULL, "", &save_ptr);
    if (queue_id == null) then
        ovs_fatal(0, "argument to -Q or --port-queue should take the form "
                  "\"<port-name>:<queue-id>\"");
    end

    if (!simap_put(&port_queues, port_name, atoi(queue_id))) then
        ovs_fatal(0, "<port-name> arguments for -Q or --port-queue must "
                  "be unique");
    end
end

local function parse_options(int argc, char *argv[])

    enum {
        OPT_MAX_IDLE = UCHAR_MAX + 1,
        OPT_PEER_CA_CERT,
        OPT_MUTE,
        OPT_WITH_FLOWS,
        OPT_UNIXCTL,
        VLOG_OPTION_ENUMS,
        DAEMON_OPTION_ENUMS,
        OFP_VERSION_OPTION_ENUMS
    };
    local long_options = {
        {"hub",         no_argument, nil , 'H'},
        {"noflow",      no_argument, nil , 'n'},
        {"normal",      no_argument, nil , 'N'},
        {"wildcards",   optional_argument, nil , 'w'},
        {"max-idle",    required_argument, nil , OPT_MAX_IDLE},
        {"mute",        no_argument, nil , OPT_MUTE},
        {"queue",       required_argument, nil , 'q'},
        {"port-queue",  required_argument, nil , 'Q'},
        {"with-flows",  required_argument, nil , OPT_WITH_FLOWS},
        {"unixctl",     required_argument, nil , OPT_UNIXCTL},
        {"help",        no_argument, nil , 'h'},
        DAEMON_LONG_OPTIONS,
        OFP_VERSION_LONG_OPTIONS,
        VLOG_LONG_OPTIONS,
        STREAM_SSL_LONG_OPTIONS,
        {"peer-ca-cert", required_argument, nil , OPT_PEER_CA_CERT},
        {nil , 0, nil , 0},
    };
    local short_options = ovs_cmdl_long_options_to_short_options(long_options);

    while (true) do
        int indexptr;
        char *error;
        int c;

        c = getopt_long(argc, argv, short_options, long_options, &indexptr);
        if (c == -1) {
            break;
        }

        switch (c) {
        case 'H':
            learn_macs = false;
            break;

        case 'n':
            set_up_flows = false;
            break;

        case OPT_MUTE:
            mute = true;
            break;

        case 'N':
            action_normal = true;
            break;

        case 'w':
            wildcards = optarg ? strtol(optarg, NULL, 16) : UINT32_MAX;
            break;

        case OPT_MAX_IDLE:
            if (!strcmp(optarg, "permanent")) {
                max_idle = OFP_FLOW_PERMANENT;
            } else {
                max_idle = atoi(optarg);
                if (max_idle < 1 || max_idle > 65535) {
                    ovs_fatal(0, "--max-idle argument must be between 1 and "
                              "65535 or the word 'permanent'");
                }
            }
            break;

        case 'q':
            default_queue = atoi(optarg);
            break;

        case 'Q':
            add_port_queue(optarg);
            break;

        case OPT_WITH_FLOWS:
            error = parse_ofp_flow_mod_file(optarg, OFPFC_ADD, &default_flows,
                                            &n_default_flows,
                                            &usable_protocols);
            if (error) {
                ovs_fatal(0, "%s", error);
            }
            break;

        case OPT_UNIXCTL:
            unixctl_path = optarg;
            break;

        case 'h':
            usage();

        VLOG_OPTION_HANDLERS
        OFP_VERSION_OPTION_HANDLERS
        DAEMON_OPTION_HANDLERS

        STREAM_SSL_OPTION_HANDLERS

        case OPT_PEER_CA_CERT:
            stream_ssl_set_peer_ca_cert_file(optarg);
            break;

        case '?':
            exit(EXIT_FAILURE);

        default:
            abort();
        }
    end
    free(short_options);

    if (!simap_is_empty(&port_queues) || default_queue != UINT32_MAX) {
        if (action_normal) {
            ovs_error(0, "queue IDs are incompatible with -N or --normal; "
                      "not using OFPP_NORMAL");
            action_normal = false;
        }

        if (!learn_macs) {
            ovs_error(0, "queue IDs are incompatible with -H or --hub; "
                      "not acting as hub");
            learn_macs = true;
        }
    }
end

local function usage(void)

    printf(string.format([[
%s: OpenFlow controller
usage: %s [OPTIONS] METHOD
where METHOD is any OpenFlow connection method.
]], program_name, program_name);
    vconn_usage(true, true, false);
    daemon_usage();
    ofp_version_usage();
    vlog_usage();
    printf("\nOther options:\n"
           "  -H, --hub               act as hub instead of learning switch\n"
           "  -n, --noflow            pass traffic, but don't add flows\n"
           "  --max-idle=SECS         max idle time for new flows\n"
           "  -N, --normal            use OFPP_NORMAL action\n"
           "  -w, --wildcards[=MASK]  wildcard (specified) bits in flows\n"
           "  -q, --queue=QUEUE-ID    OpenFlow queue ID to use for output\n"
           "  -Q PORT-NAME:QUEUE-ID   use QUEUE-ID for frames from PORT-NAME\n"
           "  --with-flows FILE       use the flows from FILE\n"
           "  --unixctl=SOCKET        override default control socket name\n"
           "  -h, --help              display this help message\n"
           "  -V, --version           display version information\n");
    
    exit();
end

main(#arg, arg);
