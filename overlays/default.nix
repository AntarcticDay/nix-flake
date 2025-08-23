
# overlays/default.nix
# =============================================================================
# Central Overlay Management
# 
# This file combines all overlays into a single list that will be applied to
# nixpkgs. Overlays allow us to modify, override, or add packages to the
# standard nixpkgs collection.
# 
# What are overlays?
# - They are functions that take two arguments: 'final' and 'prev'
# - They return an attribute set of package modifications
# - They are applied in order, each building on the previous
# =============================================================================

# Arguments: the raw package sets without our overlays applied
{ pkgsStableRaw      # Stable nixpkgs channel (no overlays)
, pkgsUnstableRaw    # Unstable nixpkgs channel (no overlays)
}:

let
  # ===========================================================================
  # Import Individual Overlays
  # ===========================================================================
  # 
  # Each overlay file handles a specific concern:
  # - Keep overlays focused and single-purpose
  # - Name files descriptively
  # - Document what each overlay does
  
  # Channels overlay: Exposes stable/unstable channels as pkgs.stable/unstable
  channelsOverlay = import ./channels.nix { 
    inherit pkgsStableRaw pkgsUnstableRaw; 
  };
  
  # SillyTavern overlay: Wraps the package to use XDG directories
  sillytavernOverlay = import ./sillytavern.nix;
  
  # ===========================================================================
  # Future Overlay Examples (commented out)
  # ===========================================================================
  
  # # Custom versions overlay: Pin specific package versions
  # versionsOverlay = import ./versions.nix;
  
  # # Patches overlay: Apply custom patches to packages
  # patchesOverlay = import ./patches.nix;
  
  # # Personal packages overlay: Add your own packages
  # personalOverlay = import ./personal.nix;

in
# ===========================================================================
# Overlay List
# ===========================================================================
# 
# IMPORTANT: Order matters! Overlays are applied sequentially.
# Later overlays can reference packages modified by earlier ones.
[
  # 1. Channels overlay (first)
  #    Must be first so other overlays can use pkgs.stable/unstable
  channelsOverlay
  
  # 2. Package modifications
  #    Modify existing packages from nixpkgs
  sillytavernOverlay
  
  # 3. Additional overlays would go here
  #    Add them in logical order based on dependencies
]

# =============================================================================
# How Overlays Work
# =============================================================================
# 
# When nixpkgs evaluates with these overlays, it:
# 
# 1. Starts with the base nixpkgs package set
# 2. Applies channelsOverlay:
#    - Adds pkgs.stable → stable channel packages
#    - Adds pkgs.unstable → unstable channel packages
# 3. Applies sillytavernOverlay:
#    - Modifies the sillytavern package
# 
# The result is a single package set with all modifications applied.
# 
# =============================================================================
# Adding New Overlays
# =============================================================================
# 
# To add a new overlay:
# 
# 1. Create a new file in this directory (e.g., ./my-overlay.nix)
# 2. Write your overlay function:
#    ```nix
#    final: prev: {
#      myPackage = prev.myPackage.override { ... };
#    }
#    ```
# 3. Import it in the let block above
# 4. Add it to the list at the appropriate position
# 
# =============================================================================
# Common Overlay Patterns
# =============================================================================
# 
# Override a package version:
# ```nix
# final: prev: {
#   somePackage = prev.somePackage.overrideAttrs (old: {
#     version = "1.2.3";
#     src = final.fetchurl { ... };
#   });
# }
# ```
# 
# Add a new package:
# ```nix
# final: prev: {
#   myNewPackage = final.callPackage ./my-package.nix { };
# }
# ```
# 
# Wrap a package with additional functionality:
# ```nix
# final: prev: {
#   wrappedPackage = final.symlinkJoin {
#     name = "wrapped-package";
#     paths = [ prev.originalPackage ];
#     buildInputs = [ final.makeWrapper ];
#     postBuild = ''
#       wrapProgram $out/bin/program --add-flags "..."
#     '';
#   };
# }
# ```
