{
  pkgs,
  lib,
  ...
}:

let
  # screenshot is a Python 3 + GTK 3 program, so it needs more than a plain
  # copy: a Python environment with PyGObject/PyCairo, the GTK typelib paths
  # from wrapGAppsHook3, and ImageMagick's `import` on PATH.
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);

  screenshot = pkgs.stdenv.mkDerivation {
    pname = "nyx-screenshot";
    version = "1.0";

    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.wrapGAppsHook3
    ];

    buildInputs = [
      pkgs.gtk3
      pkgs.gdk-pixbuf
      pkgs.pango
      pkgs.cairo
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 ${../dotfiles/bin/screenshot} $out/bin/screenshot
      runHook postInstall
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix PATH : ${
          lib.makeBinPath [
            pythonEnv
            pkgs.imagemagick
            pkgs.xclip
            pkgs.wl-clipboard
            pkgs.rofi
            pkgs.i3
            pkgs.xorg.xprop
            pkgs.xdg-utils
            pkgs.xdg-user-dirs
            pkgs.libnotify
            pkgs.coreutils
          ]
        }
      )
    '';
  };
in
{
  home.packages = [ screenshot ];

  # i3 calls the absolute path ~/.local/bin/screenshot (see dotfiles/i3/config),
  # so expose the wrapped build there as well as on PATH.
  home.file.".local/bin/screenshot".source = "${screenshot}/bin/screenshot";
}
