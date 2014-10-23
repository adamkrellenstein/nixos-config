{ config, pkgs, ... }:

let

  common = import ./common.nix;

  virtualbox = config.boot.kernelPackages.virtualbox;

  kde = pkgs.kde4;

in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

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
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.kde4.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.driSupport32Bit = true;
  services.xserver.displayManager.desktopManagerHandlesLidAndPower = false;

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
  boot.extraModulePackages = [virtualbox];
  boot.kernelModules = ["fuse" "vboxdrv" "vboxnetadp" "vboxnetflt"];

  # Packages.
  environment.systemPackages = [
    pkgs.chromiumBeta
    pkgs.encfs
    pkgs.screen
    pkgs.unrar
    pkgs.p7zip
    pkgs.zip
    pkgs.firefoxWrapper
    pkgs.vlc
    kde.konversation
    kde.kate
    kde.gwenview
    kde.okular
    kde.umbrello
    pkgs.cmake
    #pkgs.liferea
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
    pkgs.libva
    pkgs.libvdpau
    pkgs.vdpauinfo
    pkgs.pulseaudio
    virtualbox
    kde.ksnapshot
    kde.kolourpaint
    kde.kmag
    kde.kdevplatform
    kde.kdevelop
    kde.oxygen_icons
    kde.kdelibs
    kde.ktorrent
    kde.ark
    kde.kde_runtime
    kde.kdeutils
    kde.okteta
    pkgs.nix-repl
    pkgs.pavucontrol
    pkgs.stlink
    pkgs.gcc
    pkgs.clang
    pkgs.unzip
    pkgs.gnumake
    pkgs.python27
    pkgs.gcc-arm-embedded
    pkgs.printrun
    (pkgs.callPackage ./lowprio {})
    pkgs.cura
    pkgs.xscreensaver
    pkgs.gemalto-dotnetv2-pkcs11
    kde.kde_workspace
    pkgs.libusb
    #pkgs.kicad
    pkgs.avrdude
    pkgs.valgrind
    pkgs.openssl
    pkgs.gdb
    pkgs.blender
    pkgs.openscad
    pkgs.wine
    #pkgs.freecad
    pkgs.iptables
    kde.kdepim
    pkgs.gnome3.gedit
    pkgs.cloc
    pkgs.warzone2100
    pkgs.yacas
    pkgs.wireshark
    pkgs.libreoffice
    pkgs.bossa
    kde.full
  ];


  nixpkgs.config.packageOverrides = pkgs: (common.packageOverrides pkgs) // (with pkgs; {
    /* Best to have nothing here. */
  });

  # Make sure KDE finds its stuff.
  environment.pathsToLink = [
    "/share/apps"
    "/share/kde4"
  ];

  services.udev.extraRules = ''
    # Udev rules for VirtualBox.
    KERNEL=="vboxdrv",    OWNER="root", GROUP="vboxusers", MODE="0660", TAG+="systemd"
    KERNEL=="vboxnetctl", OWNER="root", GROUP="root",      MODE="0600", TAG+="systemd"
    SUBSYSTEM=="usb_device", ACTION=="add", RUN+="${virtualbox}/libexec/virtualbox/VBoxCreateUSBNode.sh $major $minor $attr{bDeviceClass}"
    SUBSYSTEM=="usb", ACTION=="add", ENV{DEVTYPE}=="usb_device", RUN+="${virtualbox}/libexec/virtualbox/VBoxCreateUSBNode.sh $major $minor $attr{bDeviceClass}"
    SUBSYSTEM=="usb_device", ACTION=="remove", RUN+="${virtualbox}/libexec/virtualbox/VBoxCreateUSBNode.sh --remove $major $minor"
    SUBSYSTEM=="usb", ACTION=="remove", ENV{DEVTYPE}=="usb_device", RUN+="${virtualbox}/libexec/virtualbox/VBoxCreateUSBNode.sh --remove $major $minor"

    # Allow user access to some USB devices.
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="3748", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="0478", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2104", TAG+="uaccess"
  '';

  # Network Configuration Daemon.
  networking.ncd.enable = true;
  networking.ncd.ncdConfDir = ./ncd;
  networking.ncd.scripts = [
      "cmdline.ncdi.nix" "main.ncd.nix" "nbd_boot.ncdi.nix" "network.ncdi.nix"
      "run_process_output.ncdi.nix" "vbox_hostonly.ncdi.nix" "temp_file.ncdi.nix"
      "dhcpd.ncdi.nix"
  ];

  # Enable PulseAudio.
  hardware.pulseaudio.enable = true;

  # Kernel.
  boot.kernelPackages = pkgs.linuxPackages_3_14;

  # VirtualBox extension pack.
  nixpkgs.config.virtualbox.enableExtensionPack = true;

  # Power buttons.
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    PowerKeyIgnoreInhibited=yes
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
  ];

  # Disable binary cache, it's insecure.
  nix.binaryCaches = [];

  # Allow "unfree" packages.
  nixpkgs.config.allowUnfree = true;

  # Distributed builds.
  nix.distributedBuilds = false;
  nix.buildMachines = [
    {
      hostName = "192.168.111.146";
      maxJobs = 6;
      sshUser = "build";
      sshKey = "/root/.ssh/id_rsa";
      system = "x86_64-linux";
    }
  ];

  # Shell aliases.
  environment.shellAliases = {
    ls = "ls --color=tty --si";
  };
}
