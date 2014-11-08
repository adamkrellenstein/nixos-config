{
  packageOverrides = pkgs: with pkgs; {
    # gvfs = gvfs.override { lightWeight = false; };
    gemalto-dotnetv2-pkcs11 = callPackage ./gemalto-dotnetv2-pkcs11 {};
    warzone2100 = warzone2100.override { withVideos = true; };
    # freetype = freetype.override { useEncumberedCode = false; };
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };
  };
}
