{ stdenv, pcsclite, boost155, zlib, automake, autoconf, libtool, pkgconfig, fetchsvn }:
stdenv.mkDerivation rec {
  name = "gemalto-dotnetv2-pkcs11";

  src = ./PKCS11dotNetV2.tar.bz2;

  buildInputs = [ pcsclite boost155 zlib automake autoconf libtool pkgconfig ];

  preConfigure = "sh autogen.sh";

  configureFlags = [ "--enable-system-boost" ];
}
