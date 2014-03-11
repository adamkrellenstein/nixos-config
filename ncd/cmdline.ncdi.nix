{ pkgs }: ''

include_guard "cmdline"

template get_kernel_cmdline_param {
    alias("_arg0") param;

    file_read("/proc/cmdline") cmdline;
    concat(" ", param, "=([^ ]*)([ \n]|$)") regex;
    regex_match(cmdline, regex) match;
    If (match.succeeded) {
        var("true") found;
        var(match.match1) value;
    } Else {
        var("false") found;
    } result;
}

''

