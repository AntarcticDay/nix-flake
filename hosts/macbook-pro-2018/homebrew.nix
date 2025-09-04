# hosts/macbook-pro-2018/homebrew.nix
# =============================================================================
# Homebrew configuration for MacBook Pro 2018
# 
# This file specifies which applications to install via Homebrew on this
# specific machine. It combines:
# - System-wide packages (defined here)
# - User-specific packages (imported from users/*/homebrew/)
# =============================================================================

{ inputs, ... }:

let
  # Import user-specific Homebrew lists
  # These are now organized per-user for better modularity
  userBrews = import ./users/stefano/homebrew/brew.nix;
  userCasks = import ./users/stefano/homebrew/cask.nix;
  userMasApps = import ./users/stefano/homebrew/mas.nix;
  
  # System-wide CLI tools
  # These are available to all users on this host
  systemBrews = [
    "watch"        # Execute a program periodically and show output
    "ncurses"      # Terminal control library
    "node"         # Node.js JavaScript runtime
    "ungit"        # Git UI
    "forgejo"      # Self-hosted forge
    "fastfetch"    # System info fetcher
  ];
in
{
  # ===========================================================================
  # nix-homebrew Configuration
  # ===========================================================================
  
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "stefano";
    mutableTaps = false;
    
    taps = {
      "homebrew/core" = inputs.homebrew-core;
      "homebrew/cask" = inputs.homebrew-cask;
    };
  };

  # ===========================================================================
  # Homebrew Package Configuration
  # ===========================================================================
  
  homebrew = {
    enable = true;
    
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "zap";
    };

    # Combine system-wide and user-specific brews
    brews = systemBrews ++ userBrews;
    
    # User-specific casks
    casks = userCasks;
    
    # User-specific Mac App Store apps
    masApps = userMasApps;
  };
}
