{ pkgs }: ''

include_guard "nbd_boot"

include "cmdline.ncdi"

template nbd_boot_detect {
    # Detect if we're being booted over NBD.
    call("get_kernel_cmdline_param", {"ai_nbd"}) nbd_param;
    var(nbd_param.result.found) is_nbd;

    # Detect NBD network interface.
    If (is_nbd) {
        call("get_kernel_cmdline_param", {"ai_net"}) net_param;
        regex_match(net_param.result.value, "^([^:]*):([^:]*):([^:]*):([^:]*)$") match;
        var(match.match1) dev;
        var(match.match2) addr;
        ipv4_mask_to_prefix(match.match3) prefix;
    } iface_info;
}

template nbd_boot_check_reserved_subnet {
    alias(_arg0) boot_detect;
    alias("_arg1") addr;

    If (boot_detect.is_nbd) {
        net.ipv4.ifnot_addr_in_network(addr, boot_detect.iface_info.addr, boot_detect.iface_info.prefix);
    };
}

''

