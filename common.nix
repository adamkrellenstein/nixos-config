{
  packageOverrides = pkgs: {
    # Smart card driver.
    gemalto-dotnetv2-pkcs11 = pkgs.callPackage ./gemalto-dotnetv2-pkcs11 {};
  };
}
