{ pkgs, ... }:

{
  # Tools that are personal to the user (not needed by the i3 session or by
  # system services). Session-critical packages are in
  # hosts/nixos/configuration.nix.
  home.packages = with pkgs; [
    # Nix editing
    nil
    nixfmt
    statix
    deadnix
    # nixd is not in nixpkgs; add the nix-community/nixd flake input if you
    # want it. nil (above) is the LSP LazyVim's Nix extra expects.

    # LazyVim / C++ and CMake extras
    llvmPackages.clang-tools
    cmake-language-server
    lldb
    gdb
    tree-sitter
    stylua
    shellcheck
    shfmt

    # CLI quality of life
    bat
    eza
    fd
    ripgrep
    fzf
    jq
    yq-go
    zoxide
    tealdeer

    # Extra dev runtimes (system-wide ones live in configuration.nix)
    nodejs
    bun
    uv
    # lean4 is installed system-wide; switch to `elan` here if you prefer
    # per-project Lean toolchains.
  ];
}
