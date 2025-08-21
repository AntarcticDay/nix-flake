
# lib/default.nix
# Central export point for all library functions

{ nixpkgs, nixpkgs-stable, nixpkgs-unstable }:

let

  systems = import ./systems.nix;

  mkPkgs = import ./mkPkgs.nix { inherit nixpkgs nixpkgs-stable nixpkgs-unstable; };

in

{

  inherit (systems) supportedSystems forAllSystems;
  inherit mkPkgs;

}
