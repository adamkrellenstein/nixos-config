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

    kdeApps_14_12 = kdeApps_14_12.override { kf5 = kf58; };
    plasma52 = plasma52.override { kf5 = kf58; };
    kde5 = kf58 // plasma52 // kdeApps_14_12;
  };
}
