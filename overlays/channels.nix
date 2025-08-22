
# overlays/channels.nix
# Overlay to expose stable and unstable channels

{ pkgsStableRaw, pkgsUnstableRaw }:

final: prev: {

  # Expose stable channel as pkgs.stable
  stable = pkgsStableRaw;
  
  # Expose unstable channel as pkgs.unstable
  unstable = pkgsUnstableRaw;

}
