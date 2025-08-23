
# overlays/channels.nix
# =============================================================================
# Channel Exposure Overlay
# 
# This overlay makes different nixpkgs channels available within a single
# package set. This allows you to mix packages from stable and unstable
# channels in your configuration.
#
# Purpose:
# - Access stable packages via `pkgs.stable.*`
# - Access unstable packages via `pkgs.unstable.*`
# - Use packages from different channels side-by-side
#
# Example usage in configuration:
# ```nix
# environment.systemPackages = with pkgs; [
#   stable.firefox        # Stable version for reliability
#   unstable.neovim      # Latest features from unstable
#   vscode               # From default channel (follows unstable)
# ];
# ```
# =============================================================================

# Function arguments - the raw package sets from different channels
{ pkgsStableRaw      # Stable channel packages (no overlays applied)
, pkgsUnstableRaw    # Unstable channel packages (no overlays applied)
}:

# Overlay function signature
# - final: the final package set after all overlays are applied
# - prev: the previous package set (before this overlay)

final: prev: {

  # ===========================================================================
  # Stable Channel
  # ===========================================================================
  # 
  # Expose the entire stable channel under `pkgs.stable`
  # This gives you access to thoroughly tested packages with fewer surprises

  stable = pkgsStableRaw;
  
  # ===========================================================================
  # Unstable Channel
  # ===========================================================================
  # 
  # Expose the entire unstable channel under `pkgs.unstable`
  # This gives you access to the latest package versions and features
  
  unstable = pkgsUnstableRaw;
  
  # ===========================================================================
  # Additional Channel Options (commented examples)
  # ===========================================================================
  
  # # You could add more channels or package sets:
  # 
  # # Specific release channel (example: 24.05)
  # # stable-24-05 = pkgsStable2405Raw;
  # 
  # # Custom package set with specific config
  # # minimal = import nixpkgs {
  # #   inherit (prev) system;
  # #   config = {
  # #     allowUnfree = false;
  # #     packageOverrides = pkgs: {};
  # #   };
  # # };
  # 
  # # Staging channel for testing
  # # staging = pkgsStagingRaw;

}

# =============================================================================
# How This Overlay Works
# =============================================================================
# 
# 1. The overlay receives raw package sets without any overlays applied
# 2. It adds them as attributes to the final package set
# 3. You can then access them with dot notation: pkgs.stable.*, pkgs.unstable.*
# 
# The channels are independent - each has its own:
# - Package versions
# - Dependency trees  
# - Configuration options
# - Applied patches
