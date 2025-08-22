
# lib/mkPkgs.nix
# Package set construction with overlays

{ nixpkgs, nixpkgs-stable, nixpkgs-unstable }:

system:

let

  #========= channels ==========================================

  # Import base channels without overlays
  pkgsStableRaw = import nixpkgs-stable {
    inherit system;
    config = { allowUnfree = true; };
  };
  
  pkgsUnstableRaw = import nixpkgs-unstable {
    inherit system;
    config = { allowUnfree = true; };
  };

  #========= / channels ========================================

  #========= overlays ==========================================

  # Import all overlays from the overlays directory
  overlays = import ../overlays { inherit pkgsStableRaw pkgsUnstableRaw; };

  #========= / overlays ========================================

  #========= pkgs ==============================================

  # Main package set with overlays applied
  pkgs = import nixpkgs {
    inherit system overlays;
    config = { allowUnfree = true; };
  };

  #========= / pkgs =============================================

in

{
  # Export only the package sets
  inherit pkgs pkgsStableRaw pkgsUnstableRaw;
}
