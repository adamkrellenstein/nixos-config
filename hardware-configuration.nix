{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      <nixpkgs/nixos/modules/profiles/all-hardware.nix>
    ];

  boot.loader.grub.device = "/dev/disk/by-id/ata-TOSHIBA_THNSNJ256GCST_Z31S10ZITSXY";

  boot.initrd.luks.devices = [
    {
      name = "enc-root";
      device = "/dev/disk/by-uuid/8702698e-cc71-4f5c-aaca-e5321c080f9f";
      allowDiscards = true;
    }
  ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/enc-root";
      fsType = "ext4";
      options = ["defaults" "noatime"];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6f027d31-26f8-4153-95a3-492cdf9bfcd4";
      fsType = "ext4";
      options = ["defaults" "noatime"];
    };

  swapDevices = [ { device = "/var/swap"; } ];

  # Hibernation config (swap file).
  boot.resumeDevice = "/dev/mapper/enc-root";
  boot.kernelParams = [ "resume_offset=14530560" ];
}
