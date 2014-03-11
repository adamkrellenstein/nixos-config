{stdenv, pkgs, bash, coreutils, utillinux}:
((pkgs.writeScriptBin "lowprio" ''
  #!${bash}/bin/bash
  exec ${coreutils}/bin/nice -n19 ${utillinux}/bin/ionice -c3 "$@"
'') // {
  buildInputs = [bash coreutils utillinux];
})
