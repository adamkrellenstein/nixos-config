{ stdenv, pcsclite, boost155, zlib, automake, autoconf, libtool, pkgconfig, fetchsvn }:
stdenv.mkDerivation rec {
  name = "gemalto-dotnetv2-pkcs11";

  src = fetchsvn {
    url = "https://svn.macosforge.org/repository/smartcardservices/trunk/SmartCardServices/src/PKCS11dotNetV2";
    rev = 160;
    sha256 = "1hv1qp12n6lymjh48g89lg7xkql8wdwhm197s3c8yakpskgq8bpr";
  };

  buildInputs = [ pcsclite boost155 zlib automake autoconf libtool pkgconfig ];

  preConfigure = "sh autogen.sh";

  configureFlags = [ "--enable-system-boost" ];
}
