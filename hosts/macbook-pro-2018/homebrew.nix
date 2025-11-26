# hosts/macbook-pro-2018/homebrew.nix
# =============================================================================
# Homebrew configuration for MacBook Pro 2018
# 
# This file manages Homebrew packages at the HOST level, combining:
# - System-wide packages (defined here)
# - User-specific packages (imported from users/*/homebrew/)
#
# Structure:
# - System brews: CLI tools available to all users
# - User brews: Imported from ./users/stefano/homebrew/brew.nix
# - User casks: Imported from ./users/stefano/homebrew/cask.nix  
# - User mas apps: Imported from ./users/stefano/homebrew/mas.nix
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
    # They will be managed by Homebrew itself
  };

  # ===========================================================================
  # Homebrew Package Configuration
  # ===========================================================================
  
  homebrew = {
    enable = true;
    
    # No need to specify core and cask - they're included by default
    # Only add third-party taps here if needed
    taps = [
      # Example of third-party taps:
      # "homebrew/services"
      # "homebrew/cask-versions"
      "d12frosted/emacs-plus"
    ];
    
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
