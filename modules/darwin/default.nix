
# modules/darwin/default.nix
# Base Darwin configuration module
# Imports all Darwin-specific modules

{ pkgs, lib, config, ... }:

{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Base Darwin settings
  nix = {
    enable = false;  # Using Determinate Systems' daemon
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
