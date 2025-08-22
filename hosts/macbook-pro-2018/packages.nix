
# hosts/macbook-pro-2018/packages.nix
# System packages specific to this host

{ pkgs, lib, ... }:

let
  collections = import ../../packages/collections.nix { inherit pkgs; };
in
{
  # System-wide packages for this host
  environment.systemPackages = 
    collections.base
    ++ (with pkgs.stable; [
      taisei
    ])
    ++ (with pkgs; [
      neofetch
      sillytavern
    ]);
}
