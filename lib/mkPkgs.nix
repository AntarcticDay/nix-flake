
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

in

{

  # Export only the package sets
  inherit pkgs pkgsStableRaw pkgsUnstableRaw;

}
