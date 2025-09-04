# modules/common/nix.nix
# =============================================================================
# Shared Nix Configuration Module
# 
# This module provides Nix settings that are common across all platforms
# (Darwin, NixOS, Linux). It sets up fundamental Nix behavior that should
# be consistent regardless of the operating system.
#
# IMPORTANT: This module is designed to work with Determinate Nix, which
# manages its own daemon and some settings. We only configure what's safe
# and useful to set at the module level.
# =============================================================================

{ lib, config, pkgs, ... }:

{
  # ===========================================================================
  # Nix Configuration
  # ===========================================================================
  
  nix = {
    # ---------------------------------------------------------------------------
    # Experimental Features
    # ---------------------------------------------------------------------------
    # 
    # Enable modern Nix features that improve user experience.
    # These are already enabled by Determinate Nix, but we declare them
    # explicitly for documentation and compatibility with standard Nix.
    
    settings = {
      # Enable flakes and new nix command
      # - "flakes": Enables flake support for reproducible configurations
      # - "nix-command": Enables the new `nix` CLI with better UX
      experimental-features = [ "nix-command" "flakes" ];
      
      # ---------------------------------------------------------------------------
      # Build Settings
      # ---------------------------------------------------------------------------
      
      # Automatic store optimization
      # Deduplicate files in the Nix store using hard links
      # This can save significant disk space
      auto-optimise-store = lib.mkDefault true;
      
      # Show more output during builds
      # Useful for debugging build issues
      # Set to false for quieter builds
      build-verbose = lib.mkDefault false;
      
      # Keep build logs for debugging
      # Logs are stored compressed in /nix/var/log/nix/drvs/
      keep-build-log = lib.mkDefault true;
      
      # ---------------------------------------------------------------------------
      # Network Settings
      # ---------------------------------------------------------------------------
      
      # Timeout for binary cache downloads (in seconds)
      # Increase if you have slow internet
      connect-timeout = lib.mkDefault 5;
      
      # Number of times to retry failed downloads
      download-attempts = lib.mkDefault 3;
      
      # ---------------------------------------------------------------------------
      # Security Settings
      # ---------------------------------------------------------------------------
      
      # Sandbox builds for security and purity
      # - true: Full sandboxing (recommended)
      # - false: No sandboxing (faster but less secure)
      # - relaxed: Allows network access during builds
      sandbox = lib.mkDefault true;
      
      # Only allow content-addressed derivations to access the network
      # This improves reproducibility
      sandbox-fallback = lib.mkDefault false;
      
      # ---------------------------------------------------------------------------
      # User Experience Settings
      # ---------------------------------------------------------------------------
      
      # Show a progress bar during builds
      # Makes long builds less mysterious
      show-trace = lib.mkDefault true;
      
      # Warn about dirty Git repositories in flakes
      warn-dirty = lib.mkDefault true;
      
      # Accept flake configurations without confirmation
      # Set to false for interactive confirmations
      accept-flake-config = lib.mkDefault true;
      
      # ---------------------------------------------------------------------------
      # Performance Settings
      # ---------------------------------------------------------------------------
      
      # Maximum number of parallel build jobs
      # "auto" uses all available CPU cores
      max-jobs = lib.mkDefault "auto";
      
      # Number of CPU cores to use per build job
      # 0 means use all available cores
      cores = lib.mkDefault 0;
      
      # Keep going with other builds if one fails
      # Useful for building multiple independent packages
      keep-going = lib.mkDefault false;
      
      # ---------------------------------------------------------------------------
      # Garbage Collection Settings
      # ---------------------------------------------------------------------------
      
      # Minimum amount of free space to maintain (in bytes)
      # GC will trigger if free space drops below this
      # 1 GB = 1073741824 bytes
      min-free = lib.mkDefault (1 * 1024 * 1024 * 1024);  # 1 GB
      
      # Target free space after GC (in bytes)
      # GC will try to free space until this amount is available
      max-free = lib.mkDefault (10 * 1024 * 1024 * 1024); # 10 GB
    };
    
    # ---------------------------------------------------------------------------
    # Registry Configuration
    # ---------------------------------------------------------------------------
    # 
    # The registry maps flake references to actual flake locations.
    # This allows commands like `nix run nixpkgs#hello` to work.
    
    registry = {
      # Pin nixpkgs to the version used by this flake
      # This ensures consistency across commands
      nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        flake = lib.mkDefault (
          # Use the nixpkgs from our flake inputs if available
          if builtins.hasAttr "inputs" config._module.args
            && builtins.hasAttr "nixpkgs" config._module.args.inputs
          then config._module.args.inputs.nixpkgs
          else null
        );
      };
    };
    
    # ---------------------------------------------------------------------------
    # Nix Path Configuration
    # ---------------------------------------------------------------------------
    # 
    # NIX_PATH is used by legacy nix commands and some tools.
    # We set it to use our pinned nixpkgs for consistency.
    
    nixPath = lib.mkDefault [
      "nixpkgs=flake:nixpkgs"
      # Add more paths if needed:
      # "nixos-config=/etc/nixos/configuration.nix"
    ];
  };
  
  # ===========================================================================
  # Environment Configuration
  # ===========================================================================
  
  environment = {
    # Environment variables related to Nix
    variables = {
      # Set the default NIX_PATH if not already set
      # This ensures nix-channel and legacy commands work
      NIX_PATH = lib.mkDefault (
        lib.concatStringsSep ":" config.nix.nixPath
      );
      
      # Editor for nix edit commands
      # Users can override this in their personal config
      # EDITOR = lib.mkDefault "vim";
    };
    
    # Shell aliases for common Nix operations
    # These work in all POSIX shells
    shellAliases = lib.mkDefault {
      # Rebuild shortcuts (platform-specific commands will override)
      nrb = "darwin-rebuild build --flake .#";
      nrs = "darwin-rebuild switch --flake .#";
      nrt = "darwin-rebuild test --flake .#";
      
      # Nix flake shortcuts
      nfu = "nix flake update";
      nfl = "nix flake lock";
      nfs = "nix flake show";
      nfc = "nix flake check";
      
      # Garbage collection
      ngc = "nix-collect-garbage";
      ngcd = "nix-collect-garbage -d";  # Delete old generations too
      
      # Store management
      nso = "nix store optimise";
      nsr = "nix store repair --verify";
      
      # Development
      ndev = "nix develop";
      nshell = "nix shell";
      nrun = "nix run";
      
      # Search and info
      nsearch = "nix search nixpkgs";
      ninfo = "nix-env -qa --description";
    };
  };
}

# =============================================================================
# Module Information
# =============================================================================
# 
# This module provides base Nix configuration that works across platforms.
# It's designed to:
# 
# 1. Work with Determinate Nix (doesn't conflict with its daemon management)
# 2. Provide sensible defaults that can be overridden
# 3. Be compatible with both Darwin and NixOS
# 4. Document all settings clearly
# 
# Platform-specific modules should import this and add their own settings:
# - Darwin: Additional macOS-specific Nix settings
# - NixOS: Additional Linux-specific Nix settings
# 
# =============================================================================
# Usage
# =============================================================================
# 
# In your host configuration or platform modules:
# ```nix
# {
#   imports = [
#     ../../modules/common/nix.nix
#   ];
#   
#   # Override specific settings if needed
#   nix.settings.max-jobs = 4;
# }
# ```
# 
# =============================================================================
# References
# =============================================================================
# 
# - Nix manual: https://nixos.org/manual/nix/stable/
# - Nix settings: https://nixos.org/manual/nix/stable/command-ref/conf-file.html
# - Determinate Nix: https://docs.determinate.systems/determinate-nix/
# 
# =============================================================================
