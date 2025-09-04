# modules/darwin/default.nix
# =============================================================================
# Darwin Modules Entry Point
# 
# This is the main entry point for all Darwin (macOS) system configuration
# modules. It imports and combines all the Darwin-specific modules to create
# a complete system configuration.
#
# Purpose:
# - Central import point for Darwin modules
# - Imports common cross-platform settings
# - Ensures all Darwin modules are loaded in the correct order
#
# Module structure:
# - This file: Imports all modules and sets Darwin-specific overrides
# - ../common/nix.nix: Cross-platform Nix settings
# - system.nix: Shell, fonts, and system-level settings
# - homebrew.nix: Homebrew package manager integration
#
# When a host imports this directory, all these modules are automatically
# included, providing a complete Darwin system configuration.
# =============================================================================

{ pkgs, lib, config, ... }:

{

  # ===========================================================================
  # Module Imports
  # ===========================================================================
  # 
  # Import all necessary configuration modules.
  # Order matters: more general modules should come before specific ones.
  
  imports = [
    # Common cross-platform Nix settings
    # This provides base Nix configuration that works on all platforms
    ../common/nix.nix
    
    # System-level configuration (shells, fonts, system preferences)
    ./system.nix
    
    # Homebrew integration for installing macOS applications
    ./homebrew.nix
    
    # Future modules could include:
    # ./security.nix     # FileVault, firewall, privacy settings
    # ./networking.nix   # Network configuration, VPN settings
    # ./launchd.nix      # LaunchAgents and LaunchDaemons management
  ];

  # ===========================================================================
  # Darwin-Specific Nix Configuration
  # ===========================================================================
  # 
  # IMPORTANT: We're using Determinate Nix, which manages its own Nix daemon
  # and configuration. We only override what's necessary for Darwin.
  
  nix = {
    # ---------------------------------------------------------------------------
    # Nix Daemon Management
    # ---------------------------------------------------------------------------
    # 
    # CRITICAL: This must be false when using Determinate Nix!
    # 
    # Why enable = false?
    # - Determinate Nix installs and manages its own Nix daemon
    # - It provides optimized configuration in /etc/nix/nix.conf
    # - It runs additional services (like Determinate Nixd for FlakeHub)
    # - Setting this to true would conflict with Determinate's setup
    # 
    # What Determinate Nix provides:
    # - Standard Nix daemon (same as upstream Nix)
    # - Automatic flakes and nix-command enablement
    # - FlakeHub authentication and caching
    # - Optimized store settings
    # - Automatic garbage collection
    # 
    # Reference: https://docs.determinate.systems/determinate-nix/
    enable = false;
    
    # ---------------------------------------------------------------------------
    # Darwin-Specific Settings
    # ---------------------------------------------------------------------------
    # 
    # These settings are specific to macOS and override the common settings
    # from ../common/nix.nix when necessary.
    
    settings = {
      # macOS-specific sandbox configuration
      # On Darwin, sandboxing requires specific entitlements
      sandbox = lib.mkDefault "relaxed";  # More compatible with macOS
      
      # Use case-sensitive file system awareness
      # macOS is typically case-insensitive, this helps Nix handle it correctly
      case-hack = lib.mkDefault true;
    };
  };

  # ===========================================================================
  # Darwin-Specific Environment
  # ===========================================================================
  
  environment = {
    # Override shell aliases for Darwin-specific commands
    shellAliases = lib.mkForce {
      # Darwin rebuild commands
      nrb = "darwin-rebuild build --flake .#";
      nrs = "darwin-rebuild switch --flake .#";
      nrt = "darwin-rebuild test --flake .#";
      nrc = "darwin-rebuild check --flake .#";
      
      # Nix flake shortcuts (inherited from common)
      nfu = "nix flake update";
      nfl = "nix flake lock";
      nfs = "nix flake show";
      nfc = "nix flake check";
      
      # Garbage collection
      ngc = "nix-collect-garbage";
      ngcd = "nix-collect-garbage -d";
      
      # Store management
      nso = "nix store optimise";
      nsr = "nix store repair --verify";
      
      # Development
      ndev = "nix develop";
      nshell = "nix shell";
      nrun = "nix run";
      
      # Search and info
      nsearch = "nix search nixpkgs";
      ninfo = "nix-env -qa --description";
    };
    
    # Darwin-specific environment variables
    variables = {
      # Ensure Nix tools are in the PATH
      # Determinate Nix handles this, but being explicit doesn't hurt
      NIX_PATH = lib.mkDefault "nixpkgs=flake:nixpkgs";
    };
  };

  # ===========================================================================
  # System Integration
  # ===========================================================================
  # 
  # Ensure Darwin system integrates well with Nix
  
  # Programs that need special Darwin integration
  programs = {
    # Enable Nix integration for shells
    # This ensures nix commands work in all shells
    bash.enable = true;  # Even if using zsh, bash should be available
    
    # Additional programs are configured in system.nix
  };

  # ===========================================================================
  # Security Settings
  # ===========================================================================
  
  # Enable Touch ID (and Apple Watch) for sudo via /etc/pam.d/sudo_local
  security.pam.services.sudo_local = {
    enable = true;        # explicitly manage /etc/pam.d/sudo_local with nix-darwin
    touchIdAuth = true;   # enable Touch ID for sudo
    # reattach = true;    # fix Touch ID inside tmux/screen (pam_reattach)
    # watchIdAuth = true; # allow Apple Watch auth for sudo (optional)
};

}

# =============================================================================
# Notes on Module Organization
# =============================================================================
# 
# This module is the entry point for Darwin-specific configuration.
# It:
# 1. Imports common cross-platform settings
# 2. Imports other Darwin modules
# 3. Provides Darwin-specific overrides
# 
# The separation allows us to:
# - Share common config across platforms
# - Keep Darwin-specific settings isolated
# - Override common settings when needed for macOS
#
# =============================================================================
