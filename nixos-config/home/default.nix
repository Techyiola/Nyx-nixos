{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./packages.nix
    ./dotfiles.nix
    ./scripts.nix
    ./systemd.nix
  ];

  home.username = "techyiola";
  home.homeDirectory = "/home/techyiola";
  home.stateVersion = "26.05"; # change to the release you install

  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # Shells
  # ---------------------------------------------------------------------------
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
    };
  };

  # config.fish is generated here instead of being copied from the old machine,
  # so Home Manager owns the file and fish can still write fish_variables.
  programs.fish = {
    enable = true;
    shellAliases = {
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      celar = "printf '\\033[2J\\033[3J\\033[1;1H'";
      claer = "printf '\\033[2J\\033[3J\\033[1;1H'";
    };
    interactiveShellInit = ''
      set fish_greeting

      function starship_transient_prompt_func
          starship module character
      end

      if test "$TERM" != linux
          starship init fish | source
          enable_transience
          alias ls 'eza --icons'
      end

      if test "$TERM" = xterm-kitty
          alias ssh 'kitten ssh'
      end
    '';
  };

  programs.git = {
    enable = true;
    userName = "Techyiola";
    userEmail = "233786865+Techyiola@users.noreply.github.com";
    extraConfig.init.defaultBranch = "main";
  };

  # ---------------------------------------------------------------------------
  # Environment
  # ---------------------------------------------------------------------------
  home.sessionVariables = {
    BROWSER = "zen-beta";
    EDITOR = "nvim";
    VISUAL = "nvim";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "18";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.elan/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/go/bin"
  ];

  # ---------------------------------------------------------------------------
  # Theming
  # ---------------------------------------------------------------------------
  gtk = {
    enable = true;
    font = {
      name = "Fira Sans";
      size = 10;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 18;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = "1";
    };
    gtk3.extraCss = ''
      * { color: #eaf0fa; }
    '';
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = "1";
    };
    gtk4.extraCss = ''
      * { color: #eaf0fa; }
    '';
  };

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    kvantum.enable = true;
  };

  # ---------------------------------------------------------------------------
  # XDG
  # ---------------------------------------------------------------------------
  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    projects = "Projects";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/chrome" = "zen-beta.desktop";
      "text/html" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";
    };
  };

  # X resources are merged by i3 at startup (`xrdb -merge ~/.Xresources`).
  home.file.".Xresources".text = ''
    Xcursor.theme: Bibata-Modern-Classic
    Xcursor.size: 18
  '';

  home.file.".config/environment.d/10-cursor.conf".text = ''
    XCURSOR_THEME=Bibata-Modern-Classic
    XCURSOR_SIZE=18
  '';
}
