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
    
    # Use mutable taps - Homebrew manages its own repositories
    # This avoids issues with immutable Nix store paths
    mutableTaps = true;
    
    # We don't specify taps here when using mutableTaps
    # They will be managed by Homebrew itself below
  };

  # ===========================================================================
  # Homebrew Package Configuration
  # ===========================================================================
  
  homebrew = {
    enable = true;
    
    # Specify taps for Homebrew to manage
    taps = [
      "homebrew/core"
      "homebrew/cask"
    ];
    
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "none";  # Temporarily disabled for safety
    };

    # Combine system-wide and user-specific brews
    brews = systemBrews ++ userBrews;
    
    # User-specific casks
    casks = userCasks;
    
    # User-specific Mac App Store apps
    masApps = userMasApps;
  };
}
