{ stdenv, bzip2, patchelf, glibc, gcc, fetchurl }:
stdenv.mkDerivation rec {
/*
  name = "gcc-arm-none-eabi-4_7-2013q3-20130916";
  src = fetchurl {
    url = "https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q3-update/+download/${name}-linux.tar.bz2";
    sha256 = "1bd9bi9q80xn2rpy0rn1vvj70rh15kb7dmah0qs4q2rv78fqj40d";
  };
*/
  name = "gcc-arm-none-eabi-4_8-2013q4-20131204";
  src = fetchurl {
    url = "https://launchpad.net/gcc-arm-embedded/4.8/4.8-2013-q4-major/+download/gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2";
    sha256 = "fd090320ab9d4b6cf8cdf29bf5b046db816da9e6738eb282b9cf2321ecf6356a";
  };
  
  buildInputs = [ bzip2 patchelf ];
  
  dontPatchELF = true;
  
  phases = "unpackPhase patchPhase installPhase";
  
  installPhase = ''
    mkdir -pv $out
    mv * $out

    for f in $(find $out)
    do
      [ -f "$f" ] && patchelf "$f" 2> /dev/null && 
      patchelf --set-interpreter ${glibc}/lib/ld-linux.so.2 \
               --set-rpath $out/lib:${gcc}/lib \
               "$f" || true
    done
  '';
}
