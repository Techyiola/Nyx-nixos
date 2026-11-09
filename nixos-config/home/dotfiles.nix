{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Scripts that are plain files and only need to be executable.
  binScripts = [
    "battery-notify"
    "bluetooth-menu-window"
    "brightness"
    "btop-window"
    "fetch-window"
    "floating-terminal"
    "lazydocker-window"
    "lock"
    "nmtui-window"
    "osd"
    "sleep-toggle"
    "volume"
  ];
in
{
  # ---------------------------------------------------------------------------
  # Config directories / files
  # ---------------------------------------------------------------------------
  xdg.configFile = {
    # Writable because set-wallpaper.sh replaces wallpaper.png in this tree.
    # Everything else in the i3 dir is still edited via the repo + rebuild.
    "i3".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos-config/dotfiles/i3";
    "polybar".source = ../dotfiles/polybar;
    "rofi".source = ../dotfiles/rofi;
    "dunst/dunstrc".source = ../dotfiles/dunst/dunstrc;
    "picom/picom.conf".source = ../dotfiles/picom/picom.conf;
    "ghostty/config.ghostty".source = ../dotfiles/ghostty/config.ghostty;
    "alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;
    "btop".source = ../dotfiles/btop;
    "xob/styles.cfg".source = ../dotfiles/xob/styles.cfg;

    "fish/functions/debloat.fish".source = ../dotfiles/fish/functions/debloat.fish;
    "fish/functions/gut.fish".source = ../dotfiles/fish/functions/gut.fish;
    "fish/functions/cachelean.fish".source = ../dotfiles/fish/functions/cachelean.fish;
    "fish/functions/temp-cleaner.fish".source = ../dotfiles/fish/functions/temp-cleaner.fish;
    "fish/functions/uvc.fish".source = ../dotfiles/fish/functions/uvc.fish;

    # LazyVim writes lazy-lock.json (and can write other files) into its
    # config dir, so this one must point at the checkout, not at the store.
    "nvim".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos-config/dotfiles/nvim";
  };

  # ---------------------------------------------------------------------------
  # ~/.local/bin helpers
  # ---------------------------------------------------------------------------
  home.file = lib.listToAttrs (map (name: {
    name = ".local/bin/${name}";
    value = {
      source = ../dotfiles/bin + "/${name}";
      executable = true;
    };
  }) binScripts) // {
    # polkit-gnome's agent lives in libexec, which is not on PATH. Wrap it so
    # i3 can call a stable path.
    ".local/bin/polkit-agent" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 "$@"
      '';
    };
  };
}
