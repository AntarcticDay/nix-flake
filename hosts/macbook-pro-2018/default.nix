# hosts/macbook-pro-2018/default.nix
# =============================================================================
# Main configuration entry point for MacBook Pro 2018
# 
# This file serves as the central configuration for this specific host.
# It imports all necessary modules and defines host-specific settings.
# =============================================================================

{ pkgs, lib, config, inputs, ... }:

{
  # ===========================================================================
  # Module Imports
  # ===========================================================================
  # 
  # We import modules in a specific order:
  # 1. System-wide modules (Darwin-specific and Home Manager)
  # 2. Host-specific configuration files
  
imports = [
    # System-wide modules
    ../../modules/darwin         # Darwin system configuration
    ../../modules/home-manager   # Home Manager integration
    
    # Host-specific configuration
    ./packages.nix              # Software packages to install
    ./homebrew.nix              # macOS apps via Homebrew
    ./home-manager.nix          # User environment setup

    # Host services (nuova posizione!)
    ./services/forgejo.nix      # Forgejo service configuration
];

  # ===========================================================================
  # Host Identification
  # ===========================================================================
  # 
  # These settings uniquely identify this machine on the network and system
  
  networking = {
    # The hostname appears in Terminal, system settings, and network
    hostName = "macbook-pro-2018";
    
    # Computer name as it appears in Finder and sharing preferences
    computerName = "MacBook Pro 2018 di Stefano";
    
    # Local hostname for Bonjour/mDNS (defaults to hostName if not set)
    localHostName = "macbook-pro-2018";
  };

  # ===========================================================================
  # System Configuration
  # ===========================================================================
  
  # Primary user account
  # This user will own the Nix store and system configuration
  system.primaryUser = "stefano";
  
  # System state version
  # IMPORTANT: Do not change this value after initial setup!
  # This ensures compatibility with the Darwin system state
  system.stateVersion = 5;  # Darwin state version (not macOS version)

  # ===========================================================================
  # Hardware-Specific Settings (MacBook Pro 2018)
  # ===========================================================================
  # 
  # These settings are specific to the 2018 Intel MacBook Pro hardware
  
  # Enable Touch ID for sudo authentication
  # (Only works on Macs with Touch ID)
  security.pam.services.sudo_local.touchIdAuth = true;

  # ===========================================================================
  # Optional: macOS System Preferences
  # ===========================================================================
  # 
  # Uncomment and modify these to manage macOS settings declaratively
  # Reference: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults
  
  system.defaults = {
  
  #   # Dock preferences
    dock = {
  #     autohide = true;
  #     show-recents = false;
  #     tilesize = 48;
    };
  
  #   # Finder preferences
    finder = {
  #     AppleShowAllExtensions = true;
  #     ShowPathbar = true;
  #     ShowStatusBar = true;
    };
  
  #   # Global macOS preferences
    NSGlobalDomain = {
  #     AppleKeyboardUIMode = 3;  # Full keyboard access
  #     ApplePressAndHoldEnabled = false;  # Key repeat
    };
  
  };

  # ===========================================================================
  # Services
  # ===========================================================================
  # 
  # Enable system services specific to this host
  
  # Nix daemon service is managed by Determinate Nix
  # Do not enable nix.* settings here as they would conflict
  
  # Example: Enable locate database updates
  # services.locate.enable = true;

  # ===========================================================================
  # Environment Variables
  # ===========================================================================
  # 
  # System-wide environment variables for this host
  
  environment.variables = {
    # Add host-specific environment variables here
    # Example: EDITOR = "vim";
  };
}
