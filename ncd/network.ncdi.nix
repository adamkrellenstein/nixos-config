{ pkgs }: ''

include_guard "network"

include "nbd_boot.ncdi"
include "cmdline.ncdi"
include "vbox_hostonly.ncdi"
include "dhcpd.ncdi"

# Some easy to change configuration.
template network_config {
    # Get information about NBD booting.
    call("nbd_boot_detect", {}) nbd_detect;

    # Prepare for choosing LAN interface.
    var("true") enable_lan;
    value({"enp4s0", "enp6s0", "enp0s3"}) lan_devs;

    # Allow overriding device via kernel command line.
    call("get_kernel_cmdline_param", {"ncd_lan"}) param;
    If (param.result.found) {
        lan_devs->reset({param.result.value});
    };

    var("true") enable_vpntv;
    var("false") enable_vpnlocal;
    var("true") enable_wlan;

    var("wlp3s0") wlan_dev;
    var("tap3") vpn_tv_dev;
    var("tap5") vpn_localnet_dev;

    var(@concatlist(lan_devs, {wlan_dev})) inet_depend;

    var({
        "127.0.0.1/8", "192.168.5.0/24",
        "10.111.0.0/24"
    }) reserved_subnets;

    var("my-badvpn") badvpn_user;

    var({"${pkgs.badvpn}/bin/badvpn-client"}) badvpn_client_cmd;

    var("/home/my-badvpn/nssdb-tv2") nssdb_tv;
    var("/home/my-badvpn/nssdb-localnet2") nssdb_localnet;
}

template network_main {
    # Get config.
    call("network_config", {}) config;

    # Set some sysctl's.
    runonce({"${pkgs.procps}/sbin/sysctl", "net.ipv4.ip_forward=1"});
    runonce({"${pkgs.procps}/sbin/sysctl", "net.ipv6.conf.all.disable_ipv6=1"});

    # Set DROP policy for FORWARD chain.
    net.iptables.policy("filter", "FORWARD", "DROP", "ACCEPT");
    net.iptables.append("filter", "FORWARD", "-m", "physdev", "--physdev-is-bridged", "-j", "ACCEPT");

    # Allow established connections.
    net.iptables.append("filter", "FORWARD", "-m", "state", "--state", "ESTABLISHED", "-j", "ACCEPT");

    # Allow all local traffic.
    net.iptables.append("filter", "INPUT", "-i", "lo", "-j", "ACCEPT");

    # Setup weak host model exceptions chain.
    net.iptables.newchain("filter", "INPUT_except");
    net.iptables.append("filter", "INPUT", "-j", "INPUT_except");

    # Add blackhole routes for private subnets.
    net.ipv4.route("10.111.0.0", "24", "blackhole", "200", "");

    # Create dependency scopes.
    depend_scope() depscope;
    depend_scope() connection_depsc;

    # Create process manager.
    process_manager() mgr;

    # Start processes.
    Foreach (config.lan_devs As lan_dev) {
        mgr->start("connection_lan", {lan_dev});
    };
    mgr->start("connection_wlan", {});
    mgr->start("internet_config", {});
    mgr->start("vpn_tv", {});
    mgr->start("vpn_localnet", {});
    #mgr->start("virtualbox", {});
    mgr->start("dnsmasq", {});
    mgr->start("natnet", {});
    mgr->start("bbb_interface", {});
}

template connection_lan {
    alias("_caller") main;
    alias("_arg0") dev;
    if(main.config.enable_lan);

    # Wait for device.
    net.backend.waitdevice(dev);
    net.up(dev);
    net.backend.waitlink(dev);

    # DHCP configuration.
    net.ipv4.dhcp(dev) dhcp;
    var(dhcp.addr) addr;
    var(dhcp.prefix) addr_prefix;
    var(dhcp.gateway) gateway;
    var(dhcp.dns_servers) dns_servers;

    # Do not allow reserved networks.
    call("check_reserved_subnets", {"_caller.main", addr});
    
    # Weak host model.
    net.iptables.append("filter", "INPUT", "-d", addr, "!", "-i", dev, "-j", "DROP");

    # Set IP address.
    net.ipv4.addr(dev, addr, addr_prefix);

    main.connection_depsc->provide(dev);
}

template connection_wlan {
    alias("_caller") main;
    if(main.config.enable_wlan);

    # Set device.
    var(main.config.wlan_dev) dev;

    # Wait for device and rfkill.
    net.backend.waitdevice(dev);
    net.backend.rfkill("wlan", dev);

    # Connect to wireless network.
    net.backend.wpa_supplicant(dev, "/etc/wpa_supplicant/all.conf", "${pkgs.wpa_supplicant}/sbin/wpa_supplicant", {}) wpa_sup;

    # DHCP configuration.
    net.ipv4.dhcp(dev) dhcp;
    var(dhcp.addr) addr;
    var(dhcp.prefix) addr_prefix;
    var(dhcp.gateway) gateway;
    var(dhcp.dns_servers) dns_servers;

    # Do not allow reserved networks.
    call("check_reserved_subnets", {"_caller.main", addr});

    # Weak host model.
    net.iptables.append("filter", "INPUT", "-d", addr, "!", "-i", dev, "-j", "DROP");

    # Set IP address. 
    net.ipv4.addr(dev, addr, addr_prefix);

    main.connection_depsc->provide(dev);
}

template internet_config {
    alias("_caller") main;

    # Wait for some network connection.
    main.connection_depsc->depend(main.config.inet_depend) ifdep;

    # Alias device values.
    var(ifdep.dev) dev;
    var(ifdep.addr) addr;
    var(ifdep.addr_prefix) addr_prefix;
    var(ifdep.gateway) gateway;
    var(ifdep.dns_servers) dns_servers;

    # Add default route.
    net.ipv4.route("0.0.0.0", "0", gateway, "20", dev);

    # Configure DNS servers.
    net.dns(dns_servers, "20");

    # Check network.
    ip_in_network(addr, "192.168.111.0", "24") is_lan;
    ip_in_network(addr, "192.168.223.0", "24") is_wlan;

    # Switch for testing VPN relaying.
    var("false") lan_relay;

    # Choose server addresses.
    call("determine_addrs", {"_caller"}) addrs;
    alias("addrs.result") addrs;

    # Build hosts entries.
    concat(addrs.vpnserver_ipaddr, " vpnserver.localnet") vpnserver_entry;

    # Build dnsmasq reload command.
    var({"/bin/sh", "-c", "kill -HUP $(cat /var/run/dnsmasq.pid); true"}) reload_dnsmasq_cmd;

    # Reload dnsmasq on shutdown.
    run({}, reload_dnsmasq_cmd);

    # Write hosts file.
    var({"/bin/sh", "-c", "echo > /etc/hosts.dnsmasq"}) undo;
    run({}, undo);
    file_write("/etc/hosts.dnsmasq", vpnserver_entry);

    # Reload dnsmasq on startup.
    runonce(reload_dnsmasq_cmd);

    main.depscope->provide("internet");
}

template determine_addrs {
    alias(_arg0) netdep;

    or(netdep.is_lan, netdep.is_wlan) is_home;
    If (is_home) {
        var("192.168.113.14") vpnserver_ipaddr;
    } else {
        var("193.77.101.149") vpnserver_ipaddr;
    } result;
}

template vpn_tv {
    alias("_caller") main;
    if(main.config.enable_vpntv);

    # Interface name.
    var(main.config.vpn_tv_dev) dev;

    # Wait for network connection.
    main.depscope->depend({"internet"}) netdep;

    # Determine configuration.
    call("vpn_tv_config", {"_caller.netdep"}) config;
    alias("config.result") config;

    # Construct some arguments.
    concat(netdep.addrs.vpnserver_ipaddr, ":53077") server_addr;
    concat("sql:", main.config.nssdb_tv) nssdb_arg;

    # Set common args.
    var({
        "--tapdev", dev,
        "--logger", "syslog", "--syslog-ident", "badvpn-ambrotv",
        "--server-name", "server",
        "--server-addr", server_addr,
        "--ssl", "--nssdb", nssdb_arg, "--client-cert-name", "peer-ambro2",
        "--transport-mode", "tcp", "--peer-ssl"
    }) common_args;

    # Build client command.
    concatlist(main.config.badvpn_client_cmd, common_args, config.args) cmd;

    # Create TAP device and set it up.
    runonce({"${pkgs.module_init_tools}/sbin/modprobe", "tun"});
    run({"${pkgs.iproute}/sbin/ip", "tuntap", "add", "dev", dev, "mode", "tap", "user", main.config.badvpn_user},
        {"${pkgs.iproute}/sbin/ip", "tuntap", "del", "dev", dev, "mode", "tap"});
    net.up(dev);

    # Start badvpn-client.
    to_string(cmd) str;
    println(str);
    daemon(cmd, ["username":main.config.badvpn_user]);

    # IP address.
    var("10.74.32.226") addr;
    var("22") addr_prefix;

    # Weak host model.
    net.iptables.append("filter", "INPUT", "-d", addr, "!", "-i", dev, "-j", "DROP");

    # IGMP version
    concat("net.ipv4.conf.", dev, ".force_igmp_version=2") igmp_sysctl;
    run({"${pkgs.procps}/sbin/sysctl", "-q", igmp_sysctl}, {});

    # IPv4 configuration.
    net.ipv4.addr(dev, addr, addr_prefix);
    net.ipv4.route("89.143.8.0", "24", "10.74.32.1", "20", dev);
    net.ipv4.route("95.176.0.0", "16", "10.74.32.1", "20", dev);

    main.depscope->provide("vpn_tv");
}

template vpn_tv_config {
    alias(_arg0) netdep;

    or(netdep.is_lan, netdep.is_wlan) is_home;
    If (is_home) {
        var({"--scope", "ambro", "--scope", "internet"}) args;
    } else {
        var({"--scope", "internet"}) args;
    } result;
}

template vpn_localnet {
    alias("_caller") main;
    if(main.config.enable_vpnlocal);

    # Interface name.
    var(main.config.vpn_localnet_dev) dev;

    # Wait for network connection.
    main.depscope->depend({"internet"}) netdep;

    # Choose bind port.
    var("55000") bind_port;

    # Compute addresses.
    concat("0.0.0.0:", bind_port) bind_addr;
    concat("192.168.5.1:", bind_port) addr_zlatkovm;
    concat("192.168.6.1:", bind_port) addr_zlatkovm6;
    concat("192.168.3.1:", bind_port) addr_zlatkopriv;

    # Determine configuration.
    call("vpn_localnet_config", {"_caller.netdep", bind_port}) config;
    alias("config.result") config;

    # Construct some arguments.
    concat(netdep.addrs.vpnserver_ipaddr, ":53072") server_addr;
    concat("sql:", main.config.nssdb_localnet) nssdb_arg;

    # Set common args.
    var({
        "--tapdev", dev,
        "--logger", "syslog", "--syslog-ident", "badvpn-localnet",
        "--server-name", "server",
        "--server-addr", server_addr,
        "--ssl", "--nssdb", nssdb_arg, "--client-cert-name", "peer-ambro",
        "--transport-mode", "udp", "--encryption-mode", "blowfish", "--hash-mode", "md5", "--otp", "blowfish", "3000", "2000",
        "--scope", "zlatkovm", "--scope", "zlatkovm6", "--scope", "zlatkopriv",
        "--bind-addr", bind_addr, "--num-ports", "20",
        "--ext-addr", addr_zlatkovm, "zlatkovm",
        "--ext-addr", addr_zlatkovm6, "zlatkovm6",
        "--ext-addr", addr_zlatkopriv, "zlatkopriv"
    }) common_args;

    # Build client command.
    concatlist(main.config.badvpn_client_cmd, common_args, config.args) cmd;

    # Create TAP device and set it up.
    runonce({"${pkgs.module_init_tools}/sbin/modprobe", "tun"});
    run({"${pkgs.iproute}/sbin/ip", "tuntap", "add", "dev", dev, "mode", "tap", "user", main.config.badvpn_user},
        {"${pkgs.iproute}/sbin/ip", "tuntap", "del", "dev", dev, "mode", "tap"});
    net.up(dev);

    # Start badvpn-client.
    daemon(cmd, ["username":main.config.badvpn_user]);

    # IP address.
    var("10.111.0.2") addr;
    var("24") addr_prefix;

    # Weak host model.
    net.iptables.append("filter", "INPUT", "-d", addr, "!", "-i", dev, "-j", "DROP");

    # IPv4 configuration.
    net.ipv4.addr(dev, addr, addr_prefix);

    main.depscope->provide("vpn_localnet");
}

template vpn_localnet_config {
    alias(_arg0) netdep;
    alias("_arg1") bind_port;

    If (netdep.is_lan) {
        concat(netdep.addr, ":", bind_port) addr_ambro;
        var({
            "--scope", "ambro", "--scope", "internet",
            "--ext-addr", addr_ambro, "ambro"
        }) args;
    } elif (netdep.is_wlan) {
        concat(netdep.addr, ":", bind_port) addr_ambrowlan;
        var({
            "--scope", "ambrowlan", "--scope", "ambro", "--scope", "internet",
            "--ext-addr", addr_ambrowlan, "ambrowlan"
        }) args;
    } else {
        var({"--scope", "internet"}) args;
    } result;
}

template virtualbox {
    alias("_caller") main;

    # Specify IP config here.
    var("192.168.56.1") addr;
    var("24") addr_prefix;
    var("192.168.56.100") dhcp_start;
    var("192.168.56.149") dhcp_end;

    # Create device.
    call("vbox_hostonly_create", {}) hostonly;
    var(hostonly.name) dev;

    # Set up.
    net.up(dev);

    # Weak host model.
    net.iptables.append("filter", "INPUT", "-d", addr, "!", "-i", dev, "-j", "DROP");

    # Assign IP address.
    net.ipv4.addr(dev, addr, addr_prefix);

    # Set up NAT.
    call("nat_rules", {"_caller.main", dev, "0x2"});

    # Run DHCP server.
    call("dhcpd_start", {addr, addr_prefix, dhcp_start, dhcp_end, {addr}, {addr}, "/run/dhcpd-vbox.conf", "/var/lib/dhcpd-vbox.leases"});
}

template natnet {
    alias("_caller") main;

    # Config.
    var("enp2s0") dev;
    var("192.168.132.1") addr;
    var("24") addr_prefix;
    var("192.168.132.100") dhcp_start;
    var("192.168.132.149") dhcp_end;

    # Wait, up.
    net.backend.waitdevice(dev);
    net.up(dev);

    # Weak host model.
    net.iptables.append("filter", "INPUT", "-d", addr, "!", "-i", dev, "-j", "DROP");

    # Assign IP address.
    net.ipv4.addr(dev, addr, addr_prefix);

    # Set up NAT.
    call("nat_rules", {"_caller.main", dev, "0x4"});

    process_manager() mgr;
    mgr->start(@natnet_dhcp, {});
    mgr->start(@natnet_nbd, {"pi2-a", "5300"});
    mgr->start(@natnet_nbd, {"pi2-b", "5301"});
    mgr->start(@natnet_nbd, {"bbb", "5302"});
}

template natnet_dhcp {
    alias("_caller") natnet;
    
    call("dhcpd_start", {natnet.addr, natnet.addr_prefix, natnet.dhcp_start, natnet.dhcp_end, {natnet.addr}, {natnet.addr}, "/run/dhcpd-natnet.conf", "/var/lib/dhcpd-natnet.leases"});
}

template natnet_nbd {
    alias(@_caller) natnet;
    alias(@_arg0) nbd_name;
    alias(@_arg1) nbd_port;
    
    var({"${pkgs.nbd}/bin/nbd-server", "-d", @concat(natnet.addr, "@", nbd_port), @concat("/var/nbd/", nbd_name, ".raw")}) nbd_cmd;
    daemon(nbd_cmd, [@username: "my_nbd", @retry_time: "1000"]);
}

template dnsmasq {
    daemon({"${pkgs.dnsmasq}/bin/dnsmasq", "-k", "-x", "/var/run/dnsmasq.pid", "--user=dnsmasq", "--group=dnsmasq"});
}

template nat_rules {
    alias(_arg0) main;
    var(_arg1) indev;
    var(_arg2) mark;

    # Wait for network connection.
    main.depscope->depend({"internet"}) netdep;

    # Build mark match.
    concat(mark, "/", mark) mark_match;

    # Add iptables rules.
    net.iptables.append("filter", "INPUT_except", "-i", indev, "-d", netdep.addr, "-j", "ACCEPT");
    net.iptables.append("filter", "FORWARD", "-i", indev, "-o", netdep.dev, "-j", "MARK", "--or-mark", mark);
    net.iptables.append("filter", "FORWARD", "-i", indev, "-o", netdep.dev, "-j", "ACCEPT");
    net.iptables.append("nat", "POSTROUTING", "-m", "mark", "--mark", mark_match, "-j", "SNAT", "--to-source", netdep.addr);
}

template check_reserved_subnets {
    alias(_arg0) main;
    var(_arg1) addr;

    # Make sure this address is not in any of the reserved
    # subnets. If it is, block here.
    Foreach (main.config.reserved_subnets As subnet) {
        net.ipv4.ifnot_addr_in_network(addr, subnet);
    };
    call("nbd_boot_check_reserved_subnet", {"_caller.main.config.nbd_detect", addr});
}

template bbb_interface {
    alias("_caller") main;

    # Basic config.
    var("enp0s26u1u4") dev;

    # Wait for device.
    net.backend.waitdevice(dev);
    net.up(dev);
    net.backend.waitlink(dev);

    # DHCP configuration.
    net.ipv4.dhcp(dev) dhcp;
    var(dhcp.addr) addr;
    var(dhcp.prefix) addr_prefix;
    var(dhcp.gateway) gateway;
    var(dhcp.dns_servers) dns_servers;

    # Do not allow reserved networks.
    call("check_reserved_subnets", {"_caller.main", addr});

    # Weak host model.
    net.iptables.append("filter", "INPUT", "-d", addr, "!", "-i", dev, "-j", "DROP");

    # Set IP address.
    net.ipv4.addr(dev, addr, addr_prefix);
}


''
