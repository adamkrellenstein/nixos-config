{ pkgs }: ''

include_guard "dhcpd"

include "temp_file.ncdi"

template dhcpd_start {
    alias("_arg0") addr;
    alias("_arg1") prefix;
    alias("_arg2") range_start;
    alias("_arg3") range_end;
    alias("_arg4") routers;
    alias("_arg5") dns_servers;
    alias("_arg6") config_file;
    alias("_arg7") leases_file;

    ipv4_net_from_addr_and_prefix(addr, prefix) network;
    ipv4_prefix_to_mask(prefix) netmask;
    implode(", ", routers) routers_str;
    implode(", ", dns_servers) dns_servers_str;

    var({"<LOCAL_ADDRESS>", "<NETWORK>", "<NETMASK>", "<RANGE_START>", "<RANGE_END>", "<ROUTERS>", "<DNS_SERVERS>"}) regex;
    var({addr, network, netmask, range_start, range_end, routers_str, dns_servers_str}) replace;

    var("
default-lease-time 600;
max-lease-time 7200;
log-facility local7;
ddns-update-style none;
local-address <LOCAL_ADDRESS>;

subnet <NETWORK> netmask <NETMASK> {
    range <RANGE_START> <RANGE_END>;
    option routers <ROUTERS>;
    option domain-name-servers <DNS_SERVERS>;
}
"   ) template_data;

    regex_replace(template_data, regex, replace) replaced_data;

    # Write the config file.
    call("temp_file_create", {config_file, replaced_data});

    # Create the leases file if it doesn't exist.
    file_stat(leases_file) stat;
    not(stat.succeeded) not_ok;
    If (not_ok) {
        file_write(leases_file, "");
    };

    # Start the DHCP daemon.
    daemon({"${pkgs.dhcp}/sbin/dhcpd", "-f", "-q", "--no-pid", "-cf", config_file, "-lf", leases_file});
}

''
