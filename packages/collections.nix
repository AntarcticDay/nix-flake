
# packages/collections.nix
# Package collections and definitions

{ pkgs }:

rec {

  #========= basePkgs ===========================================

  # Collection of essential packages
  # A collection of "must-have" packages.

  # Base packages - essential tools for all systems
  base = with pkgs.stable; [
    vim         # text editor
    curl        # HTTP / debugging tools
    git         # version control
    jq          # JSON CLI manipulation
    wget        # downloads
    nixpkgs-fmt # Nix code formatter
    emacs       # emacs
  ];

  #========= / basePkgs =========================================

  # ===================== DevShell ==============================

  # Development shell
  # enter via `nix develop`

  # Development packages
  development = with pkgs.stable; [
    htop
    neovim
  ];

  # ===================== / DevShell ============================

  # GUI applications
  gui = with pkgs.unstable; [
    alacritty
  ];

  # Default user package set
  # This is what gets installed with `nix profile install .#`
  userPackages = pkgs.buildEnv {
    name = "user-packages";
    paths = base ++ development ++ gui;
  };

  # Development shell packages
  # Available in `nix develop`
  devShellPackages = base ++ (with pkgs.stable; [
    neovim
  ]);

}
