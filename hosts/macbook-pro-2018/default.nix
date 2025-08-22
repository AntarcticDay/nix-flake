
# hosts/macbook-pro-2018/default.nix
# Main configuration for MacBook Pro 2018

{ pkgs, lib, config, inputs, ... }:

{
  # Import all modules for this host
  imports = [
    # System modules
    ../../modules/darwin
    ../../modules/home-manager
    
    # Host-specific configuration
    ./packages.nix         # Host-specific packages
    ./homebrew.nix        # Homebrew configuration
    ./home-manager.nix    # Home Manager setup
  ];

  # Host identification
  networking.hostName = "macbook-pro-2018";
  system.primaryUser = "stefano";
}
