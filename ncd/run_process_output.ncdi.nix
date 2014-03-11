{ pkgs }: ''

template run_process_output_retry {
    alias("_arg0") command;

    # Retry from here if we fail.
    var("false") retrying;
    backtrack_point() again;

    # If we're retrying, sleep for some time.
    If (retrying) {
        sleep("20000");
    };
    retrying->set("true");

    # Start child process.
    sys.start_process(command, "r", ["keep_stderr":"true"]) proc;
    If (proc.is_error) {
        again->go();
    };
    
    # Get read pipe handle.
    proc->read_pipe() read_pipe;
    If (read_pipe.is_error) {
        again->go();
    };
    
    # Read all contents.
    value("") output;
    backtrack_point() read_again;
    read_pipe->read() read;
    If (read.not_eof) {
        output->append(read);
        read_again->go();
    };
    
    # Wait for process to terminate.
    proc->wait() wait;
    val_different(wait.exit_status, "0") not_ok;
    If (not_ok) {
        again->go();
    };
}

''

