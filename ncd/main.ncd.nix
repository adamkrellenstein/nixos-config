{ pkgs }: ''

include "network.ncdi"

process main {
    process_manager() mgr;
    mgr->start("network_main", {});
}

''

