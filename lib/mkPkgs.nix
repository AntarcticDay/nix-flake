
# lib/mkPkgs.nix
# =============================================================================
# Package Set Builder with Overlay Support
# 
# This module creates customized package sets (pkgs) for different nixpkgs
# channels with our overlays applied. It's the central place where we combine
# nixpkgs channels with our modifications.
#
# What this does:
# 1. Takes different nixpkgs channels (stable, unstable)
# 2. Applies our custom overlays to modify/add packages
# 3. Returns package sets ready to use in configurations
#
# Why we need this:
# - Consistent package set creation across the flake
# - Central place to manage overlays
# - Easy access to multiple channels (stable/unstable)
# - Proper handling of unfree packages
#
# The name "mkPkgs" means "make packages" - it's a factory function
# that produces package sets for a given system.
# =============================================================================

# Function arguments - the different nixpkgs channels we'll use
{ nixpkgs          # Default nixpkgs (follows unstable in our flake)
, nixpkgs-stable   # Stable channel from FlakeHub
, nixpkgs-unstable # Latest unstable channel from GitHub
}:

# This returns a function that takes a system and returns package sets
system:

let
  # ===========================================================================
  # Base Channel Imports
  # ===========================================================================
  # 
  # First, we import the raw nixpkgs channels without any modifications.
  # These are the "vanilla" package sets straight from the channels.
  
  # ---------------------------------------------------------------------------
  # Stable Channel (Raw)
  # ---------------------------------------------------------------------------
  # 
  # The stable channel contains well-tested packages with security updates.
  # Good for: servers, production tools, anything requiring stability
  # Update cycle: ~6 months (follows NixOS releases)
  
  pkgsStableRaw = import nixpkgs-stable {
    # The system to build packages for (e.g., "x86_64-darwin")
    inherit system;
    
    # Configuration for this package set
    config = {
      # Allow proprietary/unfree packages (like VS Code, Discord, etc.)
      # Without this, Nix will refuse to install non-free software
      allowUnfree = true;
      
      # Other config options available:
      # allowBroken = false;        # Prevent broken packages
      # allowInsecure = false;      # Prevent packages with known vulnerabilities
      # permittedInsecurePackages = [ "python-2.7.18" ];  # Exceptions
    };
  };
  
  # ---------------------------------------------------------------------------
  # Unstable Channel (Raw)
  # ---------------------------------------------------------------------------
  # 
  # The unstable channel contains the latest package versions.
  # Good for: development tools, desktop apps, cutting-edge software
  # Update cycle: continuous (can change daily)
  
  pkgsUnstableRaw = import nixpkgs-unstable {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };

  # ===========================================================================
  # Overlay System
  # ===========================================================================
  # 
  # Overlays are functions that modify the package set. They can:
  # - Add new packages
  # - Modify existing packages  
  # - Add the stable/unstable channels as attributes
  
  # Import all our overlays from the overlays directory
  # We pass the raw channels so overlays can reference them
  overlays = import ../overlays { 
    inherit pkgsStableRaw pkgsUnstableRaw; 
  };

  # ===========================================================================
  # Main Package Set with Overlays
  # ===========================================================================
  # 
  # This is the primary package set that includes all our modifications.
  # It starts with the default nixpkgs and applies our overlays on top.
  
  pkgs = import nixpkgs {
    inherit system;
    
    # Apply our overlays to modify the package set
    # Overlays are applied in order, each building on the previous
    inherit overlays;
    
    config = {
      allowUnfree = true;
      
      # Additional configuration can go here
      # packageOverrides = pkgs: { };  # Legacy way to override packages
    };
  };

in
# ===========================================================================
# Return Value
# ===========================================================================
# 
# We return a set containing all our package collections.
# This is what consuming code receives when calling mkPkgs.
{
  # ---------------------------------------------------------------------------
  # Primary Package Set
  # ---------------------------------------------------------------------------
  # 
  # This is the main package set with all overlays applied.
  # It includes:
  # - All packages from the default nixpkgs channel
  # - Our custom overlays (channels, sillytavern, etc.)
  # - Access to stable/unstable via pkgs.stable.* and pkgs.unstable.*
  # 
  # Usage: pkgs.firefox, pkgs.git, pkgs.stable.postgresql, etc.
  inherit pkgs;
  
  # ---------------------------------------------------------------------------
  # Raw Channel Access
  # ---------------------------------------------------------------------------
  # 
  # These provide direct access to unmodified channels.
  # Useful when:
  # - You need a package without any overlays
  # - Debugging overlay issues
  # - Comparing modified vs unmodified packages
  # 
  # Usage: pkgsStableRaw.firefox, pkgsUnstableRaw.neovim
  inherit pkgsStableRaw pkgsUnstableRaw;
  
  # ---------------------------------------------------------------------------
  # Future Additions (examples)
  # ---------------------------------------------------------------------------
  # 
  # # Package set with different configuration
  # pkgsMinimal = import nixpkgs {
  #   inherit system;
  #   config = {
  #     allowUnfree = false;  # Only free software
  #   };
  # };
  # 
  # # Package set for static builds
  # pkgsStatic = pkgs.pkgsStatic;
  # 
  # # Package set for cross-compilation
  # pkgsCross = pkgs.pkgsCross.aarch64-multiplatform;
}

# =============================================================================
# How This Module Works - Detailed Flow
# =============================================================================
# 
# 1. **Function Structure**:
#    - Outer function receives nixpkgs channels
#    - Returns inner function that takes a system
#    - Inner function returns package sets
#    - This is called "currying" in functional programming
# 
# 2. **Package Set Creation**:
#    ```
#    nixpkgs channel → import with config → apply overlays → final pkgs
#    ```
# 
# 3. **Overlay Application**:
#    - Start with base nixpkgs
#    - Each overlay modifies the package set
#    - Later overlays can see changes from earlier ones
#    - Final result has all modifications
# 
# 4. **Channel Integration**:
#    - Raw channels imported separately
#    - Overlays add them as pkgs.stable and pkgs.unstable
#    - Allows mixing packages from different channels
#
# =============================================================================
# Usage Examples
# =============================================================================
# 
# In flake.nix:
# ```nix
# let
#   lib = import ./lib { inherit nixpkgs nixpkgs-stable nixpkgs-unstable; };
#   env = lib.mkPkgs "x86_64-darwin";
# in {
#   # Use the package set
#   packages.x86_64-darwin.default = env.pkgs.hello;
# }
# ```
# 
# In a host configuration:
# ```nix
# let
#   env = lib.mkPkgs "x86_64-darwin";
# in {
#   # System packages from different channels
#   environment.systemPackages = with env.pkgs; [
#     firefox                    # From default channel
#     stable.postgresql_14       # From stable channel
#     unstable.rust-analyzer     # From unstable channel
#   ];
# }
# ```
# 
# Accessing raw channels:
# ```nix
# # When you need packages without overlay modifications
# environment.systemPackages = [
#   env.pkgsStableRaw.nginx    # Nginx from stable, no overlays
# ];
# ```
#
# =============================================================================
# Understanding Overlays
# =============================================================================
# 
# An overlay is a function: `final: prev: { ... }`
# - `prev`: packages before this overlay
# - `final`: final package set after all overlays
# - Returns: attribute set of modifications
# 
# Example overlay:
# ```nix
# final: prev: {
#   # Add a new package
#   myPackage = final.callPackage ./my-package.nix { };
#   
#   # Modify existing package
#   firefox = prev.firefox.override {
#     cfg.enableGoogleTalk = true;
#   };
# }
# ```
#
# =============================================================================
# Configuration Options Explained
# =============================================================================
# 
# **allowUnfree**: 
# - Permits proprietary software
# - Required for: VS Code, Discord, Zoom, etc.
# - Set to false for fully open-source systems
# 
# **allowBroken**:
# - Permits packages marked as broken
# - Usually means they don't build or have issues
# - Only enable if you need a specific broken package
# 
# **allowInsecure**:
# - Permits packages with known security issues
# - Dangerous! Only use when absolutely necessary
# - Better to use permittedInsecurePackages for specific exceptions
#
# =============================================================================
# Troubleshooting
# =============================================================================
# 
# **"Package is unfree" errors**:
# - Ensure allowUnfree = true in all package sets
# - Check package license: `nix eval nixpkgs#package.meta.license`
# 
# **"infinite recursion" errors**:
# - Usually an overlay referring to itself
# - Use `prev.package` not `final.package` when overriding
# 
# **Package not found**:
# - Check spelling: `nix search nixpkgs#packagename`
# - Might only be in unstable: use `pkgs.unstable.package`
# - Might need an overlay to add it
# 
# **Performance issues**:
# - Many overlays can slow evaluation
# - Consider using fewer, more focused overlays
# - Use `--show-trace` to debug slow evaluations
