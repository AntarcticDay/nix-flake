
# modules/home-manager/default.nix
# Base Home Manager configuration module

{ lib, config, ... }:

{
  # Home Manager base settings
  home-manager = {
    useGlobalPkgs = true;    # Re-use system pkgs for faster evaluation
    useUserPackages = true;  # Make packages.* available under home.packages
  };
}
