
# lib/mkPkgs.nix

# Package set construction with overlays

{ nixpkgs, nixpkgs-stable, nixpkgs-unstable }:

system:
let

  #========= channels ==========================================

  # Import base channels without overlays
  # "raw" base channels (imported without overlays)

  pkgsStableRaw = import nixpkgs-stable {
    inherit system;
    config = { allowUnfree = true; };
  };
  
  pkgsUnstableRaw = import nixpkgs-unstable {
    inherit system;
    config = { allowUnfree = true; };
  };

  #========= / channels ========================================

  #========= Overlay ===========================================

  # Overlay to expose both channels as pkgs.stable and pkgs.unstable

  #  Overlay exposing both channels as `pkgs.stable` and `pkgs.unstable`.
  #  Allows modules to mix versions, if needed.

  channelsOverlay = final: prev: {
    stable = pkgsStableRaw;                    # pkgs.stable
    unstable = pkgsUnstableRaw;                # pkgs.unstable
  };

  #========= / Overlay =========================================

  #========= SillyTavern =======================================

  # Overlay to wrap SillyTavern with proper XDG paths

  wrapperOverlay = final: prev: {
    sillytavern = final.symlinkJoin {
      name = "sillytavern";
      paths = [ prev.sillytavern ];
      buildInputs = [ prev.makeWrapper ];       # wrapProgram helper
      postBuild = ''
        wrapProgram $out/bin/sillytavern \
          --run 'export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"' \
          --run 'export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"' \
          --run 'mkdir -p "$XDG_CONFIG_HOME/sillytavern" "$XDG_DATA_HOME/sillytavern"' \
          --add-flags "--configPath \$XDG_CONFIG_HOME/sillytavern/config.yaml" \
          --add-flags "--dataRoot  \$XDG_DATA_HOME/sillytavern"
      '';
    };
  };

  #========= / SillyTavern =====================================

  #========= pkgs ==============================================

  # Main package set with overlays applied
  # Primary package set (with channelsOverlay applied)

  pkgs = import nixpkgs {
    inherit system;
    overlays = [ channelsOverlay wrapperOverlay ];
    config = { allowUnfree = true; };
  };

  #========= / pkgs =============================================

  #========= basePkgs ===========================================

  # Collection of essential packages
  # A collection of "must-have" packages.

  basePkgs = with pkgs.stable; [
    vim         # text editor
    curl        # HTTP / debugging tools
    git         # version control
    jq          # JSON CLI manipulation
    wget        # downloads
    nixpkgs-fmt # Nix code formatter
    emacs       # emacs
  ];

  #========= / basePkgs =========================================

in {

  #========= inerit pkgs ========================================

  inherit pkgs pkgsStableRaw pkgsUnstableRaw basePkgs;

  #========= / inerit pkgs ======================================

  # ===================== Aggregate package =====================

          # install with `nix profile install .#`

  # Default package set for the system
  packages = {
    default = pkgs.buildEnv {
      name = "user-packages";
      paths = basePkgs
        ++ (with pkgs.stable; [
          htop
          neovim
        ])
        ++ (with pkgs.unstable; [
          alacritty
        ]);
    };
  };

  # ===================== / Aggregate package ===================

  # ===================== DevShell ==============================

  # Development shell
  # enter via `nix develop`

  devShells = {
    default = pkgs.mkShell {
      packages = 
        basePkgs 
        ++ (with pkgs.stable; [
          neovim
        ]);
    };
  };

  # ===================== / DevShell ============================

}
