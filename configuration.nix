# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  fileSystems."/".options  = [ "noatime" "nodiratime" "discard" ];

  # boot.kernelParams = [ "intel_pstate=no_hwp" ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
 boot.loader.grub = {
  enable = true;
  device = "nodev";
  efiSupport = true;
#	enableCryptodisk = true;
  gfxmodeEfi = "1024x768"; # faster loading, especially on high DPIs
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  boot.initrd.luks.devices = {
  root = {
  device = "/dev/disk/by-uuid/5425ab27-2acb-4c90-8a91-478ca910c66c";
  preLVM = true;
  allowDiscards = true;
  };
};


  networking.hostName = "nix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Beirut";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us,ara";
  services.xserver.xkbOptions = "grp:alt_space_toggle,caps:swapescape,altwin:menu_win";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Intel drivers
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
  Option "DRI" "2"
  Option "TearFree" "true"
  '';
  # Themes
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  # Emacs overlay
  # services.emacs.package = pkgs.emacs-unstable;


  services.xserver.displayManager = {
  lightdm.enable = false;
  startx.enable = true;
    autoLogin = {
    enable = true;
    user = "mahdi";
  };
  };
  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mahdi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    # packages = with pkgs; [
    # ];
  };

  nixpkgs.overlays = [
    # (import (builtins.fetchTarball {
    #   url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    # }))
    # Suckless overlay
    (final: prev: {
        dwm = prev.dwm.overrideAttrs (old: {
             src = /home/mahdi/.local/src/dwm ;
             #  nativeBuildInputs = [
             #     pkgs.pkg-config
             #  ];
             #  buildInputs = old.buildInputs ++ [
             #        pkgs.fribidi
             # ];
        });
    })
    (final: prev: {
        dmenu = prev.dmenu.overrideAttrs (old: {
             src = /home/mahdi/.local/src/dmenu ;
             nativeBuildInputs = [
                pkgs.pkg-config
             ];
             buildInputs = old.buildInputs ++ [
                   pkgs.fribidi
            ];
        });
    })
     (final: prev: {
      dwmblocks = prev.dwmblocks.overrideAttrs (old: { src = /home/mahdi/.local/src/dwmblocks ;});
      })
  ];
  # services.xserver.windowManager.dwm.enable = true;
  fonts = {
      fonts = with pkgs; [
      liberation_ttf
      dejavu_fonts
      noto-fonts-emoji
      wqy_microhei
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "DejaVu Sans Mono" ];
        serif = [ "Liberation Serif" "wqy_microhei" ];
        sansSerif = [ "Liberation Sans" "wqy_microhei" ];
        };
      };
  };

  services.dbus.enable = true;
  # xdg.portal = {
  #   enable = true;
  #   # wlr.enable = true;
  #   # gtk portal needed to make gtk apps happy
  #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # };
  security.polkit.enable = true;
  security = {
    pam = {
      services =
        let defaults = {
              gnupg = {
                enable = true;
                noAutostart = true;
                storeOnly = true;
              };
            };
            in {
            login = defaults;
            slock = defaults;
          };
        };
    };
 services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
    # Do not sleep on lid close
    HandleLidSwitch=ignore
  '';

   systemd = {
     extraConfig = ''
       DefaultTimeoutStopSec=5s
       '';
};
  services.cron = {
    enable = true;
    systemCronJobs = [
      # "* * * * *  . $HOME/.zprofile; datelog"
      "*/30 * * * * updatedb"
      # "*/15 * * * * . /usr/bin/mailsync; pkill -RTMIN+2 ${STATUSBAR:-dwmblocks}"
      # "*/25 * * * * . $HOME/.zprofile; /usr/bin/env DISPLAY=:0 newsup"
      # "* */12 * * * . $HOME/.zprofile; weather-report"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    # firefox
    librewolf
    # qutebrowser
    tree
    neovim
    pkg-config
    picom
    dwm
    dmenu
    dwmblocks
    speedcrunch
    # xkbmon
    # i3
    # i3blocks
    # sxhkd
    alacritty
    brightnessctl
    # obs-studio
    #namcap # to check PKGBUILD files
    gparted
    #emacs-unstable
    # emacs29
    emacs
    # emacs29-pgtk
    gomuks
    ##weechat
    #highlight
    xorg.xev
    xorg.xinit
    xorg.xkill
    xorg.xprop
    xorg.xwininfo
    xorg.xinput
    xorg.xset
    xorg.xdpyinfo
    xdotool
    zsh
    #adwaita-qt5
    dunst
    vnstat # network traffic monitoring tool
    tlp
    # other packages
    #xdo
    physlock #super tty/X locker
    isync
    neomutt
    mutt-wizard
    newsboat
    android-tools
    aria2
    aspell
    aspellDicts.en
    aspellDicts.ar
    ispell
    #net-tools
    atool
    bc
    pcmanfm
    bluez
    blueman
    #usbutils
    brightnessctl
    dosfstools
    rsync
    entr
    ffmpeg
    chromium #firefox isn't always sufficient -unfortunately-
    lynx
    flameshot
    fzf
    gimp
    imagemagick
    #gnome-keyring
    gnupg
    htop
    jq
    kdeconnect
    libnotify
    libreoffice
    texlive.combined.scheme-small
    pandoc
    maim
    gnumake
    gcc
    cmake
    mediainfo
    perl536Packages.FileMimeInfo
    mlocate
    moreutils
    mpc-cli
    mpd
    mpv
    #mtools
    ncmpcpp
    ntfs3g
    pass
    patch
    polkit
    poppler
    tk
    python39
    python311Packages.pip
    progress
    redshift
    sdcv
    tesseract4 # ocr
    # ;tesseract-data-eng
    # ;tesseract-data-ara
    socat
    #syncthing
    tmux
    tor-browser-bundle-bin
    translate-shell
    transmission
    lf
    bat
    ffmpegthumbnailer # needed for video thumbnails
    pamixer
    pulsemixer
    xautolock
    xcape
    xclip
    clipmenu
    xcolor
    xwallpaper
    exfat # might conflicts with some qemu package like in arch
    yt-dlp
    zathura
    #okular
    # ccls
    # clang
    jdk17
    go
    ripgrep
    nodejs
    # unrar
    unzip
    gnutar
    ### Docs
    #; openjdk-doc
    #; python-docs
    # ; xtrlock
    ## Programming
    shellcheck
    jetbrains.idea-community
    ##dbeaver
    virtualbox
    ## Needed Networking tools
    killall
    #net-tools
    #bind (for dig)
    #arp-scan
    #traceroute
    wireshark
    ## Outer
    ##packettracer
    # ciscoPacketTracer8
    ##sgpt
    xbanish
    nsxiv
    bicon
    urlview
    tremc
    udict # urbandict cli
    simple-mtpfs
    xdragon
    kmag
    thunderbird
    # birdtray
    #vscodium-bin # To date, I use it for debugging
    #mycli
    anki-bin
    # abook
    # pup-git # web scraping utility
    pam_gnupg
    ##musnify-mpd
    #stardict-oald
    jellyfin
    squid
    ##TODO--PIP--
    # setuptools
    # kolibri
    #; go install golang.org/x/tools/cmd/godoc@latest # go offline docs
    nodePackages_latest.browser-sync

    # dwm dependencies
    # xorg.libX11
    # xorg.libX11.dev
    # xorg.libxcb
    # xorg.libXft
    # xorg.libXinerama
    # fribidi
    # pkgs.harfbuzz
    # xorg.xinit
    # xorg.xinput

    # xdg-desktop-portal-gtk

    ###qemu stuff
    ##libvirt
    ##virt-manager
    ##virt-viewer
    ##dnsmasq
    ##vde2
    ##bridge-utils
    ##openbsd-netcat
    ##libguestfs

    ## Wayland

    # bemenu
    # pinentry-bemenu
    # sway
    # foot

    ##xdg-desktop-portal
    ##xdg-desktop-portal-wlr
    ##sway
    ##xorg-xwayland
    ##swaylock
    ##dmenu-wayland
    ##swaybg
    ##gammastep
    ##brightnessctl
    ##ibus
    ##wl-clipboard
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
