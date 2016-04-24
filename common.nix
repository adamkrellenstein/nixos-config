{
  packageOverrides = pkgs: with pkgs; {
    # Smart card driver.
    gemalto-dotnetv2-pkcs11 = callPackage ./gemalto-dotnetv2-pkcs11 {};

    # Warzone with videos.
    warzone2100 = warzone2100.override { withVideos = true; };

    # Firefox branding.
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };

    # Temporary fix for Steam.
    steamPackages = pkgs.steamPackages // {
        steam-chrootenv = pkgs.steamPackages.steam-chrootenv.override { newStdcpp = true; };
    };
    
    wine = pkgs.wine.override { wineBuild = "wineWow"; };
  };
}
