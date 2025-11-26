
# flake.nix
# =============================================================================
# Main entry point for the Determinate Nix flake configuration
# 
# This flake manages multiple systems using:
# - nix-darwin for macOS system configuration
# - Home Manager for user-specific configuration
# - Homebrew integration for macOS applications
# - Custom overlays for package modifications
#
# Structure:
# 1. Inputs: External dependencies (nixpkgs, nix-darwin, etc.)
# 2. Outputs: What this flake provides (configurations, packages, shells)
# =============================================================================

{
  # ===========================================================================
  # Flake Description
  # ===========================================================================
  # This description appears when running `nix flake show` or `nix flake metadata`
  
  description = "Determinate Nix flake";

  # ===========================================================================
  # Flake Inputs
  # ===========================================================================
  # 
  # Inputs are external dependencies that this flake needs. They are:
  # - Other flakes (nixpkgs, home-manager, etc.)
  # - Git repositories
  # - Local paths
  # 
  # Each input is pinned to a specific version in flake.lock for reproducibility
  
  inputs = {
    # -------------------------------------------------------------------------
    # Nixpkgs Channels
    # -------------------------------------------------------------------------
    # We use multiple nixpkgs channels to balance stability and features
    
    # Stable channel via FlakeHub
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    
    # Unstable channel from GitHub  
    # - Latest package versions and features
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Default nixpkgs (what you get with just `pkgs`)
    # We follow unstable for the latest packages by default
    nixpkgs.follows = "nixpkgs-unstable";
    
    # -------------------------------------------------------------------------
    # System Configuration Tools
    # -------------------------------------------------------------------------
    
    # Home Manager - Declarative user environment management
    # - Manages: dotfiles, user packages, user services
    # - Per-user configuration (each user gets their own config)
    # - Works on: NixOS, macOS, other Linux distros
    homeManager = {
      # Follow the Home Manager release that matches our stable nixpkgs (26.05)
      url = "github:nix-community/home-manager/release-26.05";
      # Keep Home Manager on the same nixpkgs release as `nixpkgs-stable`
      # so updating that input automatically updates Home Manager's base.
      inputs.nixpkgs.follows = "nixpkgs-stable";
    
    # nix-darwin - macOS system configuration
    # - Manages: system packages, services, preferences
    # - Declarative alternative to manual brew/defaults commands
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # -------------------------------------------------------------------------
    # Homebrew Integration (macOS only)
    # -------------------------------------------------------------------------
    
    # nix-homebrew - Declarative Homebrew management
    # - Manages Homebrew installation and packages via Nix
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      # Note: doesn't follow our nixpkgs, uses its own pinned version
    };
    
    # Homebrew package repositories (not flakes, just data)
    # These are the actual formula/cask definitions
    # Updated via `nix flake update` instead of `brew update`
    homebrew-core = { 
      url = "github:homebrew/homebrew-core"; 
      flake = false;  # This is data, not a flake
    };
    homebrew-cask = { 
      url = "github:homebrew/homebrew-cask"; 
      flake = false;  # This too
    };
    
    # -------------------------------------------------------------------------
    # Utility Flakes
    # -------------------------------------------------------------------------
    
    # Systems - Defines common system types (x86_64-linux, etc.)
    # Used by flake-utils for multi-system support
    systems.url = "github:nix-systems/default";
    
    # Flake-utils - Helper functions for multi-system flakes
    # Provides `eachSystem` and other utilities
    flake-utils.url = "github:numtide/flake-utils";
    
    # Treefmt-nix - Universal code formatter integration
    # Can format Nix, Python, Go, etc. with one command
    treefmt-nix.url = "github:numtide/treefmt-nix";
    
    # Flake schemas - Validation and documentation for flake outputs
    # Helps tools understand and validate our flake structure
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
  };

  # ===========================================================================
  # Flake Outputs
  # ===========================================================================
  # 
  # Outputs are what this flake provides to the world. Common types:
  # - packages: Software you can build/install
  # - devShells: Development environments
  # - darwinConfigurations: macOS system configurations
  # - nixosConfigurations: NixOS system configurations
  # - overlays: Modifications to package sets
  # - lib: Reusable functions
  #
  # The outputs function receives all inputs as arguments
  
  outputs = inputs@{ 
    self,              # This flake itself
    nixpkgs,           # Our default nixpkgs
    nixpkgs-stable,    # Stable channel
    nixpkgs-unstable,  # Unstable channel
    nix-darwin,        # macOS configuration
    homeManager,       # User configuration
    nix-homebrew,      # Homebrew integration
    ...                # All other inputs
  }:
    let
      # -----------------------------------------------------------------------
      # Import Library Functions
      # -----------------------------------------------------------------------
      # Our custom library provides utilities for:
      # - Multi-system support (forAllSystems)
      # - Package set creation with overlays (mkPkgs)
      # - System detection helpers
      
      lib = import ./lib { 
        inherit nixpkgs nixpkgs-stable nixpkgs-unstable; 
      };
      
      # Extract commonly used functions for convenience
      inherit (lib) forAllSystems mkPkgs;
      
      # -----------------------------------------------------------------------
      # Per-System Outputs Builder
      # -----------------------------------------------------------------------
      # This function generates packages and devShells for a specific system
      # It's called once for each supported system (x86_64-linux, etc.)
      
      mkSystemOutputs = system: let
        # Create package environment for this system
        # This includes all our overlays and channel setup
        env = mkPkgs system;
        
        # Import our package collections
        # These are predefined sets of packages (base, development, etc.)
        collections = import ./pkgs/collections.nix {
          pkgs = env.pkgs; 
        };
      in {
        # Packages that can be built/installed from this flake
        packages = {
          # Default package: what you get with `nix profile install .#`
          # This installs a curated set of user packages
          default = collections.userPackages;
          
          # Future: Add individual packages here
          # sillytavern = env.pkgs.sillytavern;
          # my-custom-app = env.pkgs.callPackage ./packages/my-app.nix { };
        };
        
        # Development shells for working on this flake
        devShells = {
          # Default shell: activated with `nix develop` or via direnv
          default = env.pkgs.mkShell {
            # Tools available in the dev shell
            packages = collections.devShellPackages;
            
            # Welcome message when entering the shell
            shellHook = ''
              echo "Welcome to the Determinate Nix flake development environment!"
              echo "Run 'darwin-rebuild switch --flake .#' to apply changes."
            '';
          };
          
          # Future: Specialized shells for different tasks
          # python = env.pkgs.mkShell { ... };
          # nodejs = env.pkgs.mkShell { ... };
        };
      };

      # -----------------------------------------------------------------------
      # Darwin System Configuration Builder
      # -----------------------------------------------------------------------
      # This function creates a complete macOS system configuration
      # It combines nix-darwin, home-manager, and homebrew
      
      mkDarwinSystem = { 
        hostname,  # The hostname (must match a directory in ./hosts/)
        system     # The system type (e.g., "x86_64-darwin")
      }:
        let
          # Create package environment for this system
          env = mkPkgs system;
        in
        # Build the Darwin system configuration
        nix-darwin.lib.darwinSystem {
          inherit system;
          
          # Package set with our overlays applied
          pkgs = env.pkgs;
          
          # Special arguments passed to all modules
          # These are available in every configuration file
          specialArgs = {
            inherit inputs;                    # All flake inputs
            pkgsStable = env.pkgsStableRaw;   # Raw stable packages
            pkgsUnstable = env.pkgsUnstableRaw; # Raw unstable packages
          };
          
          # Configuration modules to load
          # Order matters: base modules first, then our customizations
          modules = [
            # Base nix-darwin module (required)
            nix-darwin.darwinModules.simple
            
            # Home Manager integration
            # This adds home-manager options to the configuration
            homeManager.darwinModules.home-manager
            
            # Homebrew integration
            # This adds homebrew options to the configuration
            nix-homebrew.darwinModules.nix-homebrew
            
            # Host-specific configuration
            # Loads all .nix files from ./hosts/${hostname}/
            ./hosts/${hostname}
            
            # Future: Add shared modules here
            # ./modules/common.nix
            # ./modules/security.nix
          ];
        };

      # -----------------------------------------------------------------------
      # NixOS System Configuration Builder (for future use)
      # -----------------------------------------------------------------------
      # Placeholder for future NixOS systems
      
      # mkNixosSystem = { hostname, system }:
      #   nixpkgs.lib.nixosSystem {
      #     inherit system;
      #     modules = [
      #       ./hosts/${hostname}
      #       homeManager.nixosModules.home-manager
      #     ];
      #   };

    in 
    # =========================================================================
    # Actual Flake Outputs
    # =========================================================================
    {
      # -----------------------------------------------------------------------
      # Multi-System Outputs
      # -----------------------------------------------------------------------
      # These are built for all supported systems
      
      # Packages
      # Access with: nix build .#packages.x86_64-darwin.default
      packages = forAllSystems (system: 
        (mkSystemOutputs system).packages
      );
      
      # Development shells
      # Access with: nix develop or direnv
      devShells = forAllSystems (system: 
        (mkSystemOutputs system).devShells
      );
      
      # -----------------------------------------------------------------------
      # System Configurations
      # -----------------------------------------------------------------------
      
      # macOS system configurations (one per host)
      # Apply with: darwin-rebuild switch --flake .#macbook-pro-2018
      darwinConfigurations = {
        # MacBook Pro 2018 (Intel)
        "macbook-pro-2018" = mkDarwinSystem {
          hostname = "macbook-pro-2018";
          system = "x86_64-darwin";
        };
        
        # Future: Add more macOS systems here
        # "macbook-pro-m5" = mkDarwinSystem {
        #   hostname = "macbook-pro-m5";
        #   system = "aarch64-darwin";
        # };
      };
      
      # NixOS configurations (for future use)
      # Apply with: nixos-rebuild switch --flake .#hostname
      # nixosConfigurations = {
      #   "nixos-server" = mkNixosSystem {
      #     hostname = "nixos-server";
      #     system = "x86_64-linux";
      #   };
      # };
      
      # -----------------------------------------------------------------------
      # Other Outputs
      # -----------------------------------------------------------------------
      
      # Flake schemas for validation (optional)
      schemas = inputs.flake-schemas.schemas;
      
      # Overlays that can be used by other flakes
      # overlays.default = import ./overlays { ... };
      
      # Reusable modules
      # darwinModules.default = ./modules/darwin;
      # nixosModules.default = ./modules/nixos;
      
      # Templates for creating new systems
      # templates.default = {
      #   path = ./templates/default;
      #   description = "Basic system configuration";
      # };
    };
}

# =============================================================================
# Usage Guide
# =============================================================================
# 
# **Building the system:**
# ```bash
# # Apply the configuration (macOS)
# $ darwin-rebuild switch --flake .#macbook-pro-2018
# 
# # Or explicitly specify the flake path
# $ darwin-rebuild switch --flake /path/to/flake#macbook-pro-2018
# ```
# 
# **Development workflow:**
# ```bash
# # Enter development shell
# $ nix develop
# 
# # Or use direnv (automatic)
# $ echo "use flake" > .envrc
# $ direnv allow
# ```
# 
# **Installing user packages:**
# ```bash
# # Install default package set
# $ nix profile install .#
# 
# # Install from a specific system
# $ nix profile install .#packages.x86_64-darwin.default
# ```
# 
# **Updating dependencies:**
# ```bash
# # Update all inputs
# $ nix flake update
# 
# # Update specific input
# $ nix flake lock --update-input nixpkgs
# ```
# 
# **Adding a new host:**
# 1. Create directory: `mkdir -p hosts/new-hostname`
# 2. Add configuration files (copy from existing host)
# 3. Add to darwinConfigurations or nixosConfigurations
# 4. Apply: `darwin-rebuild switch --flake .#new-hostname`
# 
# =============================================================================
