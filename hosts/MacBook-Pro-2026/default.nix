# Host configuration for MacBook Pro 2026 (Apple M5 Pro, aarch64-darwin)
{ pkgs, lib, inputs, ... }:
{
  imports = [
    ../../modules/common/nix.nix
    ../../modules/darwin
    ./packages.nix
    ./home-manager.nix
    ./homebrew.nix
    ./users/stefano/default.nix
  ];

  # Usa Lix come implementazione di Nix
  nix.package = pkgs.lix;

  # Architettura Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "MacBook-Pro-2026";

  system.stateVersion = 5;
}