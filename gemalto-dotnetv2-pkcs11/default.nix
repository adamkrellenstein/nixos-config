{ stdenv, pcsclite, boost155, zlib, automake, autoconf, libtool, pkgconfig, fetchsvn }:
stdenv.mkDerivation rec {
  name = "gemalto-dotnetv2-pkcs11";

  src = ./PKCS11dotNetV2.tar.bz2;
  #src = stdenv.lib.cleanSource ./PKCS11dotNetV2;

  buildInputs = [ pcsclite boost155 zlib automake autoconf libtool pkgconfig ];

  preConfigure = ''
    sed -i 's/__out/__xxxout/g' MarshallerCfg.h cardmod.h
    sh autogen.sh
  '';

  configureFlags = [ "--enable-system-boost" ];
}
