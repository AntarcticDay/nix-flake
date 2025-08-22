
# overlays/default.nix
# Central point to combine all overlays

{ pkgsStableRaw, pkgsUnstableRaw }:

let

  # Import individual overlays

  channelsOverlay = import ./channels.nix { inherit pkgsStableRaw pkgsUnstableRaw; };
  sillytavernOverlay = import ./sillytavern.nix;

in [

  # Order matters: overlays are applied in sequence

  channelsOverlay
  sillytavernOverlay

]
