
# modules/darwin/homebrew.nix
# Homebrew module configuration
# This is imported by hosts but the actual packages are defined per-host

{ inputs, lib, config, ... }:

{
  # Import nix-homebrew configuration from host
  # The host will define the actual taps, brews, casks, and masApps
  
  # Base Homebrew behavior settings
  homebrew = lib.mkIf config.homebrew.enable {
    onActivation = lib.mkDefault {
      autoUpdate = false;  # Avoid git pull in nix-store
      upgrade = true;      # Upgrade existing packages
      cleanup = "zap";     # Remove unlisted packages
    };
  };
}
