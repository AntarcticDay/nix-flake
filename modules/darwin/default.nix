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
    # -------------------------------------------------------------------------
    # Nix Daemon Management
    # -------------------------------------------------------------------------
    #
    # enable = true: nix-darwin gestisce il demone Nix e scrive /etc/nix/nix.conf.
    # Questo è corretto per Lix, che si comporta come Nix standard.
    # (Era false quando si usava Determinate Nix, che gestiva il proprio demone.)
    enable = true;

    settings = {
      # macOS: la sandbox "relaxed" è più compatibile con le build Darwin
      sandbox = lib.mkDefault "relaxed";

      # Consapevolezza del filesystem case-insensitive di macOS
      # case-hack = lib.mkDefault true;

      # Cache binaria di Lix: velocizza i download usando i binari pre-compilati
      always-allow-substitutes = lib.mkDefault true;
      extra-trusted-substituters = [ "https://cache.lix.systems" ];
      extra-trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
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
