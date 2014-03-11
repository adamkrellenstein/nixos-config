{ pkgs }: ''

include_guard "vbox_hostonly"

include "run_process_output.ncdi"

template vbox_hostonly_create {
    # Call VBoxManage to create interface.
    var("/run/current-system/sw/bin/VBoxManage") vboxmanage;
    call("run_process_output_retry", {{vboxmanage, "hostonlyif", "create"}}) run;
    
    # Extract the interface name from the output.
    regex_match(run.output, "^Interface '([a-zA-Z0-9]+)'") match;
    var(match.match1) name;
    
    # Arrange for the interface to be removed.
    run({}, {vboxmanage, "hostonlyif", "remove", name});
}

''
