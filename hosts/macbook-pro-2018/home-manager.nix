
# hosts/macbook-pro-2018/home-manager.nix
# Home Manager configuration for this host

{ lib, ... }:

{
  # User definition
  users.users.stefano = {
    name = "stefano";
    home = lib.mkDefault "/Users/stefano";
  };

  # Home Manager setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    
    # Import user configuration
    users.stefano = import ./stefano.nix;
  };
}
