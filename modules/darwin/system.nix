
# modules/darwin/system.nix
# System-level Darwin configuration
# Handles shells, fonts, and other system settings

{ pkgs, lib, config, ... }:

{
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
