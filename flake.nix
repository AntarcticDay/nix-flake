
# flake.nix
# Main entry point for the Nix flake configuration
# This flake manages macOS systems using nix-darwin, Home Manager, and Homebrew

{
  description = "Determinate Nix flake for managing macOS and NixOS systems";

  ######################################################################
  # Flake inputs (upstream dependencies)
  ######################################################################

  inputs = {
    # ======== nixpkgs ===============================================

    # Stable channel via FlakeHub (rolling releases)
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*";

    # Unstable channel directly from GitHub
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Default nixpkgs follows unstable
    nixpkgs.follows = "nixpkgs-unstable";

    # ======== OS-level configuration managers =======================

    # Home Manager - declarative per-user configuration
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin - macOS system manager
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ======== Homebrew support (Darwin) =============================

    # nix-homebrew - Homebrew bootstrapper
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    # Homebrew taps (non-flake sources)
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };

    # ======== Utilities =============================================

    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
  };

  ######################################################################
  # Flake outputs
  ######################################################################

  outputs = inputs@{ 
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-unstable,
    nix-darwin,
    homeManager,
    nix-homebrew,
    ... 
  }:
    let
      # Import library functions
      lib = import ./lib { inherit nixpkgs nixpkgs-stable nixpkgs-unstable; };
      
      # Extract needed functions from lib
      inherit (lib) forAllSystems mkPkgs;

      # Build outputs for a specific system
      mkSystemOutputs = system: let
        env = mkPkgs system;
        collections = import ./packages/collections.nix { pkgs = env.pkgs; };
      in {
        packages = {
          default = collections.userPackages;
        };
        
        devShells = {
          default = env.pkgs.mkShell {
            packages = collections.devShellPackages;
          };
        };
      };

      # Darwin system configuration builder
      mkDarwinSystem = { hostname, system }:
        let
          env = mkPkgs system;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          pkgs = env.pkgs;
          
          specialArgs = {
            inherit inputs;
            pkgsStable = env.pkgsStableRaw;
            pkgsUnstable = env.pkgsUnstableRaw;
          };
          
          modules = [
            # Base darwin module
            nix-darwin.darwinModules.simple
            
            # Home Manager module
            homeManager.darwinModules.home-manager
            
            # nix-homebrew module
            nix-homebrew.darwinModules.nix-homebrew
            
            # Host-specific configuration
            ./hosts/${hostname}
          ];
        };

    in {
      # Multi-system outputs (packages and devShells)
      packages = forAllSystems (system: (mkSystemOutputs system).packages);
      devShells = forAllSystems (system: (mkSystemOutputs system).devShells);
      
      # Darwin configurations (one per host)
      darwinConfigurations = {
        "macbook-pro-2018" = mkDarwinSystem {
          hostname = "macbook-pro-2018";
          system = "x86_64-darwin";
        };
      };
      
      # Flake schemas for validation (optional)
      # schemas = inputs.flake-schemas.schemas;
    };
}
