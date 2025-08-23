
# packages/collections.nix
# =============================================================================
# Package Collections and Definitions
# 
# This file defines reusable collections of packages that can be shared across
# different hosts and configurations. Think of it as your package "menu" where
# you define groups of related packages.
# =============================================================================

{ pkgs }:

# We use 'rec' to allow collections to reference each other
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
    emacs            # Powerful, extensible text editor
  ];

  # ===========================================================================
  # Development Package Collection
  # ===========================================================================
  # 
  # Tools for software development and system monitoring.
  # Install these on development machines or when debugging.
  
  development = with pkgs.stable; [
    # System monitoring
    htop             # Interactive process viewer (better than 'top')

    # Additional development tools can be added here:
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
    # Terminal emulators
    # alacritty        # Fast, GPU-accelerated terminal
    
    # More GUI apps can be added here:
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
  # This is what gets installed when someone runs: nix profile install .#
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
    
    # Shell-specific tools:
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
  # For a minimal server:
  # ```nix
  # environment.systemPackages = collections.base;
  # ```
  # 
  # For a development workstation:
  # ```nix
  # environment.systemPackages = 
  #   collections.base ++ 
  #   collections.development ++ 
  #   collections.gui;
  # ```

  # ===========================================================================
  # Custom Collections
  # ===========================================================================
  # 
  # You can add more specialized collections here. Examples:
  
  # # Data science tools
  # datascience = with pkgs.stable; [
  #   python3
  #   jupyter
  #   pandas
  # ];
  # 
  # # DevOps tools
  # devops = with pkgs.stable; [
  #   docker
  #   kubernetes-helm
  #   terraform
  # ];
  # 
  # # Security tools
  # security = with pkgs.stable; [
  #   gnupg
  #   pass
  #   yubikey-manager
  # ];
}
