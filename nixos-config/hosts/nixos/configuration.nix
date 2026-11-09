# System-level configuration for Nyx-X.
#
# Hardware values (filesystems, swap, kernel modules) live in
# ./hardware-configuration.nix, which you MUST regenerate on the target
# machine with `nixos-generate-config`.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ---------------------------------------------------------------------------
  # Boot
  # ---------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This machine is UEFI + btrfs. If you ever install on BIOS, replace the two
  # lines above with:
  #   boot.loader.grub.enable = true;
  #   boot.loader.grub.device = "/dev/sda";

  # CachyOS ships linux-cachyos-bore. Closest NixOS equivalents:
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_cachyos;  # if present in nixpkgs

  boot.kernelParams = [ "quiet" "splash" "udev.log_level=3" ];
  boot.supportedFilesystems = [ "btrfs" "xfs" "f2fs" "exfat" "ntfs" ];
  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt"; # cachyos-plymouth-theme is not packaged

  # ---------------------------------------------------------------------------
  # Hardware: AMD Ryzen 5 5600H (Cezanne) + NVIDIA RTX 2050 (GA107)
  # ---------------------------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # NVIDIA PRIME offload. Bus IDs come from `lspci` on this machine.
  # The AMD iGPU is the primary display; the dGPU is used on demand.
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # GA107 supports the open kernel modules. Set to false if suspend breaks.
    open = true;

    nvidiaSettings = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:4:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  # ---------------------------------------------------------------------------
  # X11, i3, and the display manager
  # ---------------------------------------------------------------------------
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.windowManager.i3.enable = true;

  # The i3 module enables programs.i3lock by default; point it at the colour
  # fork so both names resolve to one package and there is no file collision.
  programs.i3lock.package = pkgs.i3lock-color;

  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "i3";

  # i3 itself runs `xset s off -dpms`; this makes sure it is also applied
  # outside the window manager (e.g. before i3 starts).
  # services.xserver.displayManager.sessionCommands = ''
  #   ${pkgs.xorg.xset}/bin/xset s off -dpms
  # '';

  # ---------------------------------------------------------------------------
  # Audio (PipeWire)
  # ---------------------------------------------------------------------------
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  # ---------------------------------------------------------------------------
  # Networking
  # ---------------------------------------------------------------------------
  networking.hostName = "Nyx-X";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ---------------------------------------------------------------------------
  # Bluetooth
  # ---------------------------------------------------------------------------
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ---------------------------------------------------------------------------
  # Desktop / power / device services
  # ---------------------------------------------------------------------------
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.fwupd.enable = true;
  services.locate.enable = true;
  services.logrotate.enable = true;
  services.openssh.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Laptop lid behaviour (sleep-toggle can still inhibit this at runtime).
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  zramSwap.enable = true;

  # ---------------------------------------------------------------------------
  # Containers
  # ---------------------------------------------------------------------------
  virtualisation.docker.enable = true;

  # ---------------------------------------------------------------------------
  # Locale / time
  # ---------------------------------------------------------------------------
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN.UTF-8";
  console.keyMap = "us";

  # ---------------------------------------------------------------------------
  # Nix
  # ---------------------------------------------------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------------------
  # Fonts
  # ---------------------------------------------------------------------------
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    fira-sans
    dejavu_fonts
    liberation_ttf
    cantarell-fonts
  ];
  fonts.fontconfig.enable = true;

  # ---------------------------------------------------------------------------
  # System packages
  #
  # Session-wide tools live here so they are available to i3, systemd user
  # units, and all shells. Personal dev tools live in home/packages.nix.
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Window manager / X11
    i3
    polybar
    rofi
    dunst
    picom
    feh
    xob
    xorg.xrandr
    xorg.xset
    xorg.xprop
    xorg.xrdb
    xorg.xwininfo
    xorg.xinput
    xclip
    libnotify
    xss-lock
    dex
    snixembed
    polkit_gnome

    # Terminals and shell
    ghostty
    alacritty
    fish
    starship
    eza
    fzf
    ripgrep
    fd
    jq
    psmisc
    procps
    util-linux

    # Desktop apps
    (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
    firefox
    kdePackages.dolphin
    kdePackages.haruna
    libreoffice-fresh
    obs-studio
    vlc
    mpv
    yazi

    # Editors
    neovim
    vim
    nano
    micro
    opencode

    # System helpers
    networkmanager
    pamixer
    brightnessctl
    pulsemixer
    blueman
    bluetui
    bluez
    imagemagick
    upower
    powertop

    # Dev toolchain
    git
    go
    rustc
    cargo
    clang
    cmake
    gnumake
    gcc
    python3
    lean4
    docker-compose
    docker-buildx
    lazydocker
    lazygit

    # CLI utilities
    btop
    fastfetch
    cmatrix
    ncdu
    duf
    glances
    unrar
    unzip
    rsync
    pv
    wget
    less
    which
    libva-utils

    # Theme / cursor
    bibata-cursors
    papirus-icon-theme
    nordic
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
  ];

  # ---------------------------------------------------------------------------
  # Users
  # ---------------------------------------------------------------------------
  users.users.techyiola = {
    isNormalUser = true;
    description = "Techyiola";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "docker"
    ];
    shell = pkgs.fish;
    # Password is intentionally not stored here. Run `passwd techyiola`
    # after the first boot, or use a hashedPasswordFile.
  };

  programs.fish.enable = true;

  system.stateVersion = "26.05"; # change to the release you install
}
