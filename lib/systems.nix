
# lib/systems.nix
# System-related utilities and constants

let

  # List of systems we want to support
  supportedSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

in

{

  # Export the list of supported systems
  inherit supportedSystems;

  # Helper function to generate outputs for all supported systems
  forAllSystems = f: builtins.listToAttrs (map (system: {
    name = system;
    value = f system;
  }) supportedSystems);

}
