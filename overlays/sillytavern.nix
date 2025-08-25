
# overlays/sillytavern.nix
# =============================================================================
# SillyTavern Standalone Installation Overlay
# 
# This creates a wrapper that runs SillyTavern entirely from ~/.SillyTavern
# Reference: https://mynixos.com/nixpkgs/package/sillytavern
# =============================================================================

final: prev: {
  
  sillytavern = final.writeShellScriptBin "sillytavern" ''
    # Define SillyTavern home directory
    SILLYTAVERN_HOME="$HOME/.SillyTavern"
    
    # First time setup: copy entire SillyTavern to user directory
    if [ ! -d "$SILLYTAVERN_HOME" ]; then
      echo "🚀 First time setup - Installing SillyTavern to $SILLYTAVERN_HOME"
      echo "This may take a moment..."
      
      # Create directory
      mkdir -p "$SILLYTAVERN_HOME"
      
      # Copy entire SillyTavern installation
      cp -r ${prev.sillytavern}/opt/sillytavern/* "$SILLYTAVERN_HOME/"
      
      # Make sure we have write permissions
      chmod -R u+w "$SILLYTAVERN_HOME"
      
      echo "✅ Installation complete!"
      echo ""
    fi
    
    # Always run from SillyTavern directory
    cd "$SILLYTAVERN_HOME"
    
    # Run SillyTavern with Node.js
    echo "🎭 Starting SillyTavern from $SILLYTAVERN_HOME"
    echo "📡 Server will be available at http://localhost:8000"
    echo ""
    
    exec ${final.nodejs}/bin/node server.js "$@"
  '';
}
