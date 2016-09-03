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

/*
    linux_4_4 = pkgs.linux_4_4.override {
      kernelPatches = pkgs.linux_4_4.kernelPatches ++ [
        { patch = /home/ambro/Downloads/patch-4.4.17-rt25.patch; name = "rt"; }
      ];
    };
*/

    stdenv = pkgs.stdenv // {
      platform = pkgs.stdenv.platform // {
        kernelExtraConfig = "PREEMPT y";
      };
    };
  };
}
