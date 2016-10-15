{
  packageOverrides = pkgs: {
    # Smart card driver.
    gemalto-dotnetv2-pkcs11 = pkgs.callPackage ./gemalto-dotnetv2-pkcs11 {};

    # Warzone with videos.
    warzone2100 = pkgs.warzone2100.override { withVideos = true; };

    # Temporary fix for Steam.
    steamPackages = pkgs.steamPackages // {
        steam-chrootenv = pkgs.steamPackages.steam-chrootenv.override { newStdcpp = true; };
    };
    
    wine = pkgs.wine.override { wineBuild = "wineWow"; };
  };
}
