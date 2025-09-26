
# packages/collections.nix
# =============================================================================
# Package Collections and Definitions
# 
# Reusable package groups for hosts and dev shells.
# =============================================================================

{ pkgs }:

# 'rec' is used to allow collections to reference each other
rec {
  # ===========================================================================
  # Base Package Collection
  # ===========================================================================
  # 
  # Essential packages that should be available on all systems.
  # These are the "must-have" tools for basic system operation.
  
  base = with pkgs.stable; [

    # Text editing
    vim              # Classic terminal text editor
    neovim           # Modern vim fork with better plugin support

    # Network tools
    curl             # Transfer data from/to servers (HTTP, FTP, etc.)
    wget             # Download files from the web
    
    # Version control
    git              # Essential for managing code and configurations
    
    # Data processing
    jq               # Command-line JSON processor (parse, filter, transform)
    
    # Nix tools
    nixpkgs-fmt      # Format Nix files for consistent style
    
    # Emacs editor
    # emacs            # Powerful, extensible text editor
  ];

  # ===========================================================================
  # Development Package Collection
  # ===========================================================================
  # 
  # Tools for software development and system monitoring.
  
  development = with pkgs.stable; [

    htop             # Interactive process viewer (better than 'top')

    # ripgrep        # Fast file search
    # fd             # User-friendly 'find' alternative
    # bat            # 'cat' with syntax highlighting
    # delta          # Better git diffs
  ];

  # ===========================================================================
  # GUI Application Collection
  # ===========================================================================
  # 
  # Graphical applications for desktop use.
  # Only install these on systems with a graphical environment.
  
  gui = with pkgs.unstable; [
    # alacritty        # Fast, GPU-accelerated terminal emulator
    # firefox        # Web browser
    # vscode         # Visual Studio Code
    # slack          # Team communication
  ];

  # ===========================================================================
  # Combined Package Sets
  # ===========================================================================
  # 
  # These combine multiple collections for different use cases
  
  # ---------------------------------------------------------------------------
  # Default User Packages
  # ---------------------------------------------------------------------------
  # 
  # Gets installed with: nix profile install .#  
  # It creates a single derivation containing all specified packages

  userPackages = pkgs.buildEnv {
    name = "user-packages";
    
    # Combine collections into a single package set
    paths = base ++ development ++ gui;
    
    # buildEnv options:
    # pathsToLink = [ "/bin" "/share" ];  # Which subdirectories to link
    # extraOutputsToInstall = [ "man" "doc" ];  # Include documentation
    # meta.priority = 5;  # Resolution priority for conflicts
  };

  # ---------------------------------------------------------------------------
  # Development Shell Packages
  # ---------------------------------------------------------------------------
  # 
  # Packages available in the development shell (nix develop)
  # Keep this minimal to reduce shell activation time
  
  devShellPackages = base ++ (with pkgs.stable; [
    # Additional tools only needed during development
    neovim           # For quick edits in the dev shell

    # direnv         # Automatic environment switching
    # lorri          # Nix shell daemon
  ]);

  # ===========================================================================
  # Usage Examples
  # ===========================================================================
  # 
  # In a host configuration (e.g., hosts/my-machine/packages.nix):
  # ```nix
  # let
  #   collections = import ../../packages/collections.nix { inherit pkgs; };
  # in {
  #   environment.systemPackages = collections.base ++ collections.development;
  # }
  # ```
  #
  # ===========================================================================

}
