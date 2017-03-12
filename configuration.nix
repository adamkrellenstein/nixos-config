{ config, pkgs, ... }:

let

  common = import ./common.nix;

  kde4 = pkgs.kde4;
  kde5 = pkgs.kde5;

  rt_kernel = false;

in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.timeout = 1;

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
  #services.xserver.videoDrivers = ["nouveau"];
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.driSupport32Bit = true;
  services.xserver.synaptics.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # SDDM with KDE theme.
  services.xserver.displayManager.sddm = {
    enable = true;
    theme = "breeze";
    themes = [
      kde5.plasma-workspace
      (kde5.oxygen-icons or kde5.oxygen-icons5)
    ];
  };

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
    pkgs.openocd
    pkgs.awscli
    pkgs.graphviz
    pkgs.ntfs3g
    pkgs.manpages
    pkgs.posix_man_pages
    pkgs.stdmanpages
    pkgs.smartmontools
    pkgs.pv
    pkgs.glxinfo
    pkgs.libreoffice
    pkgs.teensy-loader-cli
    pkgs.xfce.xfce4_xkb_plugin
    pkgs.xfce.xfce4_whiskermenu_plugin
    kde4.konversation
    kde4.ktorrent
    kde4.ksnapshot
    kde4.kolourpaint
    kde4.kdepim
    kde4.kcachegrind
    kde4.oxygen_icons
    #kde4.kdevelop
    pkgs.kdevelop
    kde5.frameworkintegration
    kde5.kinit
    kde5.breeze
    kde5.kde-cli-tools
    kde5.oxygen
    kde5.oxygen-icons5
    pkgs.hicolor_icon_theme
    kde5.systemsettings
    kde5.okular
    kde5.gwenview
    kde5.filelight
    kde5.ark
    kde5.kcalc
    kde5.plasma-workspace-wallpapers
    kde5.konsole
    kde5.kate
    kde5.ksysguard
    pkgs.vanilla-dmz
    pkgs.firefox
  ];

  nixpkgs.config.packageOverrides = pkgs: (common.packageOverrides pkgs) // (with pkgs; {
    stdenv = pkgs.stdenv // {
      platform = pkgs.stdenv.platform // {
        kernelExtraConfig = if rt_kernel then "PREEMPT_RT_FULL y" else "PREEMPT y";
      };
    };
  });

  services.udev.extraRules = ''
    # Allow user access to some USB devices.
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="3748", TAG+="uaccess", RUN{builtin}+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="0478", TAG+="uaccess", RUN{builtin}+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2104", TAG+="uaccess", RUN{builtin}+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1457", ATTR{idProduct}=="5118", TAG+="uaccess", RUN{builtin}+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1fc9", ATTR{idProduct}=="000c", TAG+="uaccess", RUN{builtin}+="uaccess"

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
  hardware.pulseaudio.support32Bit = true;

  # Kernel.
  boot.kernelPackages = if rt_kernel then pkgs.linuxPackages_4_4_rt else pkgs.linuxPackages_4_4;

  # VirtualBox extension pack.
  nixpkgs.config.virtualbox.enableExtensionPack = true;

  # Power buttons.
  services.logind.extraConfig = ''
    HandlePowerKey=hibernate
    HandleSuspendKey=hibernate
    HandleHibernateKey=hibernate
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
  #nix.extraOptions = ''
  #  gc-keep-outputs = true
  #  gc-keep-derivations = true
  #'';

  # Build in sandbox.
  nix.useSandbox = true;

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
    pkgs.noto-fonts
  ];

  # Parallel building.
  nix.buildCores = 3;
  nix.maxJobs = 2;

  # Allow "unfree" packages.
  nixpkgs.config.allowUnfree = true;

  # Shell aliases.
  environment.shellAliases = {
    ls = "ls --color=tty --si";
  };

  # NTP.
  services.ntp.enable = true;
  services.ntp.servers = [ "192.168.111.1" ];
  systemd.services.ntpd.wantedBy = [ "multi-user.target" ];

  # VirtualBox.
  virtualisation.virtualbox.host.enable = !rt_kernel;
  virtualisation.virtualbox.host.addNetworkInterface = false;

  # Time zone.
  time.timeZone = "CET";

  # Bluetooth.
  hardware.bluetooth.enable = true;
  
  # User account for NBD servers.
  users.users.my_nbd = {
    description = "Network Block Device servers";
    isSystemUser = true;
    group = "my_nbd";
  };
  users.extraGroups.my_nbd = {};

  # Swappiness.
  boot.kernel.sysctl."vm.swappiness" = 1;

  # We have nixpkgs in our own place.
  environment.sessionVariables.NIX_PATH = pkgs.lib.mkForce "nixpkgs=/etc/nixos/nixpkgs:nixos-config=/etc/nixos/configuration.nix";

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

  # Clean /tmp on boot.
  boot.cleanTmpDir = true;

  # Make sure some packages are preserved during GC.
  system.extraDependencies = [pkgs.stdenv];

  # SMART
  services.smartd.enable = true;
  services.smartd.notifications.x11.enable = true;

  # Gnome keyring
  services.gnome3.gnome-keyring.enable = true;

  # Make sure KDE finds its stuff.
  environment.pathsToLink = ["/share"];

  services.xserver.inputClassSections = [
    ''
      Identifier "Ignore keyboard mouse device"
      MatchIsKeyboard "on"
      MatchProduct "Logitech Gaming Mouse G300"
      Option "Ignore" "on"
    ''
  ];

  # Chromium WideVine plugin (for Netflix).
  #nixpkgs.config.chromium.enableWideVine = true;

  security.pam.loginLimits = [
    { domain = "ambro"; item = "memlock"; type = "-"; value = "100000"; }
    { domain = "ambro"; item = "rtprio"; type = "-"; value = "80"; }
  ];
}
