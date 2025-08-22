
# hosts/macbook-pro-2018/default.nix
# Main configuration for MacBook Pro 2018

{ pkgs, lib, config, inputs, ... }:

{
  # Import all modules for this host
  imports = [
    ./packages.nix              # Host-specific packages
    ./homebrew.nix             # Homebrew configuration
    ./home-manager.nix         # Home Manager setup
  ];

  # Host identification
  networking.hostName = "macbook-pro-2018";
  system.primaryUser = "stefano";

  # Basic system configuration
  nix = {
    enable = false;  # Using Determinate Systems' daemon
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Shell configuration
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh pkgs.bash ];

  # System fonts
  fonts.packages = with pkgs; [
    ibm-plex
    iosevka
    jetbrains-mono
    lexend
    xits-math
    atkinson-hyperlegible-next
    atkinson-hyperlegible-mono
  ];
}
