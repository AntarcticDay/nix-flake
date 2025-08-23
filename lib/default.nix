
# lib/default.nix
# =============================================================================
# Library functions and utilities
# 
# This is the central export point for all library functions used throughout
# the flake. It provides reusable utilities for system management, package
# handling, and cross-platform support.
# =============================================================================

# Function arguments: the different nixpkgs channels we're using
{ nixpkgs          # Default nixpkgs (follows unstable)
, nixpkgs-stable   # Stable channel from FlakeHub  
, nixpkgs-unstable # Latest unstable channel
}:

let

  # ===========================================================================
  # Import Sub-modules
  # ===========================================================================
  # 
  # Each file in lib/ handles a specific aspect:
  # - systems.nix: Platform/architecture support utilities
  # - mkPkgs.nix: Package set construction with overlays
  
  # System-related utilities (supported platforms, helper functions)
  systems = import ./systems.nix;
  
  # Package set builder - creates nixpkgs instances with our overlays
  # We pass all nixpkgs channels so it can create different package sets
  mkPkgs = import ./mkPkgs.nix { 
    inherit nixpkgs nixpkgs-stable nixpkgs-unstable; 
  };

in

# ===========================================================================
# Exported Library Interface
# ===========================================================================
# 
# This is what gets imported when other files do:
# let lib = import ./lib { ... };

{
  # ---------------------------------------------------------------------------
  # System Support Functions
  # ---------------------------------------------------------------------------
  # From systems.nix - utilities for multi-platform support
  
  # List of all supported system architectures
  # Example: [ "x86_64-linux" "aarch64-darwin" ... ]
  inherit (systems) supportedSystems;
  
  # Helper to build outputs for all supported systems
  # Usage: forAllSystems (system: { package = ...; })
  # This ensures your flake works on Linux, macOS, different CPUs, etc.
  inherit (systems) forAllSystems;
  
  # ---------------------------------------------------------------------------
  # Package Management Functions  
  # ---------------------------------------------------------------------------
  # From mkPkgs.nix - package set construction
  
  # Function to create a package set for a specific system
  # Usage: mkPkgs "x86_64-darwin"
  # Returns: { pkgs, pkgsStableRaw, pkgsUnstableRaw }
  inherit mkPkgs;
  
  # ===========================================================================
  # Usage Examples
  # ===========================================================================
  # 
  # In flake.nix:
  # ```nix
  # let
  #   lib = import ./lib { inherit nixpkgs nixpkgs-stable nixpkgs-unstable; };
  # in {
  #   # Build packages for all systems
  #   packages = lib.forAllSystems (system: {
  #     default = (lib.mkPkgs system).pkgs.hello;
  #   });
  # }
  # ```
  # 
  # In a host configuration:
  # ```nix
  # let
  #   env = lib.mkPkgs "x86_64-darwin";
  # in {
  #   environment.systemPackages = with env.pkgs; [ git vim ];
  # }
  # ```

}
