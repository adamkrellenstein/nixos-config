{
  packageOverrides = pkgs: with pkgs; {
    # Smart card driver.
    gemalto-dotnetv2-pkcs11 = callPackage ./gemalto-dotnetv2-pkcs11 {};

    # Warzone with videos.
    warzone2100 = warzone2100.override { withVideos = true; };

    # Freetype make fonts less ugly.
    # freetype = freetype.override { useEncumberedCode = false; };

    # Firefox branding.
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };

    kf5_stable = kf59;
    kdeApps_stable = kdeApps_15_04;
  };
}
