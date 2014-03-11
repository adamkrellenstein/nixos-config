{ pkgs }: ''

include_guard "temp_file"

template temp_file_create {
    alias("_arg0") file_path;
    alias("_arg1") contents;

    run({}, {"/run/current-system/sw/bin/rm", file_path});
    file_write(file_path, contents);
}

''
