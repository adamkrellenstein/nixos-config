{ stdenv, python27Packages, fetchgit }:
python27Packages.buildPythonPackage rec {
    name = "printrun";

    src = fetchgit {
        url = "https://github.com/kliment/Printrun";
        rev = "36eff4ab1f33da4774d2a97403674b7500fbae5c";
        sha256 = "1awdmjzvijq03qsdy5x7ljjdpdsqafv5rf69g7474b3bfav4lss7";
    };

    patches = [ ./printrun.patch ];

    propagatedBuildInputs = [ python27Packages.wxPython python27Packages.pyserial ];

    doCheck = false;
    noOldAndUnmanageable = true;

    postInstall = ''
        for f in $out/share/applications/*.desktop; do
            sed -i -e "s|/usr/|$out/|g" "$f"
        done
    '';

    meta = with stdenv.lib; {
        description = "Pronterface, Pronsole, and Printcore - Pure Python 3d printing host software";
        homepage = https://github.com/kliment/Printrun;
        license = licenses.gpl3;
        platforms = platforms.linux;
    };
}
