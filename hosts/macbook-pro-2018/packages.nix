
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
  
  # ===========================================================================
  # Package Channel Selection
  # ===========================================================================
  # 
  # We have access to multiple package channels:
  # - pkgs (default, follows unstable)
  # - pkgs.stable (stable channel via FlakeHub)
  # - pkgs.unstable (latest unstable channel)
  # 
  # Use stable for production tools, unstable for cutting-edge software
  
in
{
  # ===========================================================================
  # System Packages Configuration
  # ===========================================================================
  # 
  # These packages will be installed in /run/current-system/sw/
  # and available in the PATH for all users
  
  environment.systemPackages = 
    # Start with the base collection (essential tools)
    collections.base
    
    # Add packages from the stable channel
    # Format: ++ (with pkgs.stable; [ package1 package2 ])
    ++ (with pkgs.stable; [

      # Gaming
      # taisei           # Open-source Touhou Project clone

    ])
    
    # Add packages from the default channel (unstable)
    # These packages might have newer features but could be less stable
    ++ (with pkgs; [

      # System information
      neofetch         # System info display tool
      
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
  # 
  # Package sources:
  # - collections.base: Defined in ../../packages/collections.nix
  # - pkgs.stable: Stable NixOS channel (reliable, tested)
  # - pkgs: Unstable channel (latest versions)
  
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
