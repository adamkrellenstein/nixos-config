{ config, pkgs, ... }:

let

  common = import ./common.nix;

  kde = pkgs.kde4;
  
  kf5 = pkgs.kf5_stable;
  plasma5 = pkgs.plasma5_stable.override { inherit kf5; };
  kdeApps = pkgs.kdeApps_stable.override { inherit kf5; };

in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.timeout = 1;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.extraConfig = ''
    Match user shared
        X11Forwarding no
        AllowTcpForwarding no
        ForceCommand internal-sftp
  '';

  # Disable cron.
  services.cron.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplip];

  # Desktop.
  services.xserver.enable = true;
  services.xserver.displayManager.kdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.driSupport32Bit = true;
  services.xserver.displayManager.desktopManagerHandlesLidAndPower = false;
  services.xserver.synaptics.enable = true;

  # Polkit.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
           action.id == "org.freedesktop.udisks2.encrypted-unlock-system"
          ) &&
          subject.local && subject.active && subject.isInGroup("users")) {
              return polkit.Result.YES;
      }
    });
  '';

  # Kernel modules.
  boot.kernelModules = ["fuse"];

  # Packages.
  environment.systemPackages = [
    pkgs.chromium
    pkgs.encfs
    pkgs.screen
    pkgs.unrar
    pkgs.p7zip
    pkgs.zip
    pkgs.vlc
    pkgs.hplip
    pkgs.cryptsetup
    pkgs.gparted
    pkgs.git
    pkgs.subversion
    pkgs.file
    pkgs.strace
    pkgs.binutils
    pkgs.fuse
    pkgs.badvpn
    pkgs.psmisc
    pkgs.nix-repl
    pkgs.pavucontrol
    pkgs.stlink
    pkgs.gcc
    pkgs.clang
    pkgs.unzip
    pkgs.gnumake
    pkgs.python27Full
    pkgs.gcc-arm-embedded
    pkgs.printrun
    pkgs.cura
    pkgs.xscreensaver
    pkgs.gemalto-dotnetv2-pkcs11
    pkgs.avrdude
    pkgs.valgrind
    pkgs.gdb
    pkgs.openscad
    pkgs.iptables
    pkgs.wireshark
    pkgs.bossa
    pkgs.nixopsUnstable
    pkgs.steam
    kde.konversation
    kde.kdevelop
    pkgs.openocd
    kde.ktorrent
    pkgs.awscli
    pkgs.graphviz
    pkgs.ntfs3g
    pkgs.manpages
    pkgs.posix_man_pages
    pkgs.pthreadmanpages
    pkgs.stdmanpages
    pkgs.hicolor_icon_theme
  ]
  ++ builtins.filter pkgs.lib.isDerivation (builtins.attrValues kf5)
  ++ [
    kdeApps.okular
    kdeApps.gwenview
    kdeApps.ksnapshot
    kdeApps.kolourpaint
    kdeApps.kdepim
    kdeApps.filelight
    kdeApps.ark
    kdeApps.kcachegrind
    kdeApps.kcalc
    kdeApps.kde-wallpapers
    kdeApps.kde-baseapps
    kdeApps.kde-runtime
    kdeApps.konsole
    kdeApps.oxygen-icons
  ];

  nixpkgs.config.packageOverrides = pkgs: (common.packageOverrides pkgs) // (with pkgs; {
    /* Best to have nothing here. */
  });

  # Make sure KDE finds its stuff.
  environment.pathsToLink = [
    "/share"
  ];

  services.udev.extraRules = ''
    # Allow user access to some USB devices.
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="3748", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="0478", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2104", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1457", ATTR{idProduct}=="5118", TAG+="uaccess"

    # MTP Samsung Galaxy S5 Mini.
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="6860", SYMLINK+="libmtp", MODE="660", ENV{ID_MTP_DEVICE}="1"
  '';

  # Network Configuration Daemon.
  networking.ncd.enable = true;
  networking.ncd.ncdConfDir = ./ncd;
  networking.ncd.scripts = [
      "cmdline.ncdi.nix" "main.ncd.nix" "nbd_boot.ncdi.nix" "network.ncdi.nix"
      "run_process_output.ncdi.nix" "vbox_hostonly.ncdi.nix" "temp_file.ncdi.nix"
      "dhcpd.ncdi.nix"
  ];
  networking.networkmanager.enable = false;

  # Enable PulseAudio.
  hardware.pulseaudio.enable = true;

  # Kernel.
  boot.kernelPackages = pkgs.linuxPackages_3_14;

  # VirtualBox extension pack.
  nixpkgs.config.virtualbox.enableExtensionPack = true;

  # Power buttons.
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandleSuspendKey=suspend
    HandleHibernateKey=suspend
    HandleLidSwitch=ignore
    HandleLidSwitchDocked=ignore

    PowerKeyIgnoreInhibited=yes
    SuspendKeyIgnoreInhibited=yes
    HibernateKeyIgnoreInhibited=yes
    LidSwitchIgnoreInhibited=yes
  '';

  # Nix daemon priorities.
  nix.daemonNiceLevel = 19;
  nix.daemonIONiceLevel = 7;

  # Nix keep build dependencies.
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';

  # Build in chroot.
  nix.useChroot = true;

  # Smart card.
  services.pcscd.enable = true;

  # Fonts.
  fonts.enableCoreFonts = true;
  fonts.fonts = [
    pkgs.ubuntu_font_family
    pkgs.ttf_bitstream_vera
    pkgs.liberation_ttf
    pkgs.libertine
    pkgs.freefont_ttf
    pkgs.dejavu_fonts
    plasma5.oxygen-fonts
  ];

  # Disable binary cache, it's insecure.
  #nix.binaryCaches = [];
  
  # Parallel building.
  nix.buildCores = 2;
  nix.maxJobs = 2;

  # Allow "unfree" packages.
  nixpkgs.config.allowUnfree = true;

  # Shell aliases.
  environment.shellAliases = {
    ls = "ls --color=tty --si";
  };

  # NTP.
  services.ntp.enable = true;
  services.ntp.servers = [ "ntp1.arnes.si" "ntp.siol.net" ];
  systemd.services.ntpd.wantedBy = [ "multi-user.target" ];

  # VirtualBox.
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.addNetworkInterface = false;

  # Time zone.
  time.timeZone = "CET";

  # Bluetooth.
  hardware.bluetooth.enable = true;
  
  # User account for NBD servers.
  users.extraUsers.my_nbd = {
    description = "Network Block Device servers";
    isSystemUser = true;
    group = "my_nbd";
  };
  users.extraGroups.my_nbd = {};

  # Swappiness.
  boot.kernel.sysctl."vm.swappiness" = 1;

  # We have nixpkgs in our own place.
  environment.sessionVariables.NIX_PATH = pkgs.lib.mkForce "nixpkgs=/etc/nixos/nixpkgs:nixos-config=/etc/nixos/configuration.nix";

  # Support running under VirtualBox.
  #virtualisation.virtualbox.guest.enable = true;

  # Wireshark.
  security.setuidOwners = [
    {
       program = "dumpcap";
       owner = "root";
       group = "wireshark";
       setuid = true;
       setgid = false;
       permissions = "u+rx,g+x";
    }
  ];
  users.extraGroups.wireshark.gid = 500;
}
