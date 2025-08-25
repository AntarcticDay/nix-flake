
# hosts/macbook-pro-2018/packages.nix
# =============================================================================
# System-wide packages for MacBook Pro 2018
# 
# This file defines which packages should be installed system-wide on this
# specific host. These packages will be available to all users.
# =============================================================================

{ pkgs, lib, ... }:

let
  # Import package collections from our shared definitions
  # This allows us to reuse common package sets across different hosts
  collections = import ../../packages/collections.nix { inherit pkgs; };

in

{
  # ===========================================================================
  # System Packages Configuration
  # ===========================================================================
  # 
  # These packages will be installed in /run/current-system/sw/
  # and available in the PATH for all users
  
  environment.systemPackages = 

    # Base collection (essential tools)
    collections.base
    
    # Packages from the stable channel
    # Format: ++ (with pkgs.stable; [ package1 package2 ])
    ++ (with pkgs.stable; [
      # taisei           # Open-source Touhou Project clone
    ])
    
    # Packages from the default channel (unstable)
    # Format: ++ (with pkgs.unstable; [ package1 package2 ])
    ++ (with pkgs.unstable; [

      # System information
      fastfetch        # Fast system info (works on macOS)
      # neofetch       # System info display tool (commented - incompatible with macOS)
      
      # AI/Chat applications
      sillytavern      # AI chat interface (with our custom overlay)

    ]);

  # ===========================================================================
  # Package Management Notes
  # ===========================================================================
  # 
  # To see installed packages:
  # $ nix-store -q --requisites /run/current-system | grep -E '^/nix/store/[^-]+-'
  # 
  # To search for packages:
  # $ nix search nixpkgs <package-name>
  # 
  # To test a package without installing:
  # $ nix run nixpkgs#<package-name>

  # ===========================================================================
  # Optional: Package-specific Configuration
  # ===========================================================================
  # 
  # Some packages may need additional configuration. Examples:
  
  # Enable shell completion for system packages
  # environment.pathsToLink = [ "/share/bash-completion" "/share/zsh" ];
  
  # Set default editor (if vim/neovim is installed)
  # environment.variables.EDITOR = "vim";
  
  # Configure package-specific environment variables
  # environment.variables.PACKAGE_CONFIG = "value";

}

  # =============================================================================
  # References
  # =============================================================================
  # 
  # - nixpkgs manual: https://nixos.org/manual/nixpkgs/
  # - nix command: https://nixos.org/manual/nix/
  #
  # =============================================================================
