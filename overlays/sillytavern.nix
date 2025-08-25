
# overlays/sillytavern.nix
# =============================================================================
# SillyTavern XDG Wrapper Overlay - FIXED VERSION
# 
# This overlay modifies the SillyTavern package to follow XDG Base Directory
# specifications and fixes the working directory issue.
# =============================================================================

final: prev: {
  
  sillytavern = final.symlinkJoin {
    name = "sillytavern";
    paths = [ prev.sillytavern ];
    buildInputs = [ prev.makeWrapper ];
    
    postBuild = ''
      # Remove the original symlink to the binary
      rm $out/bin/sillytavern
      
      # Create a new wrapper script
      cat > $out/bin/sillytavern << 'EOF'
      #!${final.bash}/bin/bash
      
      # Set XDG directories with defaults
      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
      
      # Create directories if they don't exist
      mkdir -p "$XDG_CONFIG_HOME/sillytavern" "$XDG_DATA_HOME/sillytavern"
      
      # IMPORTANT: Change to the data directory before starting SillyTavern
      # This ensures relative paths like 'data/cookie-secret.txt' work correctly
      cd "$XDG_DATA_HOME/sillytavern"
      
      # If config doesn't exist in XDG location, copy the default
      if [ ! -f "$XDG_CONFIG_HOME/sillytavern/config.yaml" ]; then
        echo "Creating default config at $XDG_CONFIG_HOME/sillytavern/config.yaml"
        cp ${prev.sillytavern}/opt/sillytavern/default/config.yaml "$XDG_CONFIG_HOME/sillytavern/config.yaml"
      fi
      
      # Create necessary subdirectories in the data folder
      mkdir -p data characters chats groups worlds themes vectors backups logs user default
      
      # Execute the original sillytavern with proper arguments
      exec ${prev.sillytavern}/bin/sillytavern \
        --configPath "$XDG_CONFIG_HOME/sillytavern/config.yaml" \
        --dataRoot "$XDG_DATA_HOME/sillytavern" \
        "$@"
      EOF
      
      # Make the wrapper executable
      chmod +x $out/bin/sillytavern
    '';
  };
}
