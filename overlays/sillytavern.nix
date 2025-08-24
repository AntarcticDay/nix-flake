
# overlays/sillytavern.nix
# =============================================================================
# SillyTavern XDG Wrapper Overlay
# 
# This overlay modifies the SillyTavern package to follow XDG Base Directory
# specifications. Instead of storing configuration and data in the current
# directory, it will use standard locations.
# 
# Reference: https://mynixos.com/nixpkgs/package/sillytavern
# =============================================================================

# Overlay function signature: final is the final package set, prev is the previous
final: prev: {
  
  # ===========================================================================
  # SillyTavern Package Override
  # ===========================================================================
  # 
  # We're replacing the original sillytavern package with a wrapped version
  # that respects XDG directories for better organization and backup management
  
  sillytavern = final.symlinkJoin {
    # The name of our wrapped package
    name = "sillytavern";
    
    # Start with the original sillytavern package
    paths = [ prev.sillytavern ];
    
    # We need makeWrapper to modify how the program starts
    buildInputs = [ prev.makeWrapper ];
    
    # Post-build phase: This runs after symlinkJoin creates the symlinks
    postBuild = ''
      # Wrap the sillytavern executable with our modifications
      wrapProgram $out/bin/sillytavern \
        --run 'export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"' \
        --run 'export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"' \
        --run 'mkdir -p "$XDG_CONFIG_HOME/sillytavern" "$XDG_DATA_HOME/sillytavern"' \
        --add-flags "--configPath \$XDG_CONFIG_HOME/sillytavern/config.yaml" \
        --add-flags "--dataRoot \$XDG_DATA_HOME/sillytavern"
    '';
    
    # =========================================================================
    # What this wrapper does:
    # =========================================================================
    # 
    # 1. Sets XDG environment variables if not already set:
    #    - XDG_CONFIG_HOME defaults to ~/.config
    #    - XDG_DATA_HOME defaults to ~/.local/share
    # 
    # 2. Creates directories if they don't exist:
    #    - ~/.config/sillytavern/ for configuration
    #    - ~/.local/share/sillytavern/ for data
    # 
    # 3. Passes command-line flags to sillytavern:
    #    - --configPath: Where to store config.yaml
    #    - --dataRoot: Where to store characters, chats, etc.
    # 
    # =========================================================================
    # Directory Structure After Running:
    # =========================================================================
    # 
    # ~/.config/sillytavern/
    # └── config.yaml          # Main configuration file
    # 
    # ~/.local/share/sillytavern/
    # ├── characters/          # Character definitions
    # ├── chats/              # Chat histories
    # ├── groups/             # Group chats
    # ├── worlds/             # World info
    # └── themes/             # UI themes
    # 
    # =========================================================================
  };
}

# =============================================================================
# Technical Notes
# =============================================================================
# 
# Why use symlinkJoin?
# - It creates a new derivation that symlinks all files from the original
# - Allows us to modify just the executable without rebuilding the package
# - More efficient than override/overrideAttrs for simple wrappers
# 
# Why use wrapProgram?
# - It creates a shell script wrapper around the original binary
# - Allows setting environment variables and adding command-line arguments
# - The original binary remains unchanged
# 
# The double dollar signs ($$) in the wrapper:
# - $out is a Nix variable (the output path)
# - \$ escapes the dollar sign for the shell script
# - ''${} is Nix string interpolation syntax with escaped $
# 
# =============================================================================
# Troubleshooting
# =============================================================================
# 
# If SillyTavern isn't finding the config:
# 1. Check that directories exist: ls -la ~/.config/sillytavern
# 2. Verify the wrapper: cat $(which sillytavern)
# 3. Run with debug: XDG_CONFIG_HOME=/tmp/test sillytavern
# 
# To reset configuration:
# 1. Stop SillyTavern
# 2. Backup: cp -r ~/.config/sillytavern ~/.config/sillytavern.bak
# 3. Remove: rm -rf ~/.config/sillytavern ~/.local/share/sillytavern
# 4. Restart (will create fresh config)
#
# =============================================================================
