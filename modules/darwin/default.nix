
# modules/darwin/default.nix
# Base Darwin configuration module
# Imports all Darwin-specific modules

{ pkgs, lib, config, ... }:

{

  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Base Darwin settings
  nix = {

    enable = false;
    # IMPORTANT: We set 'enable = false' because we're using Determinate Nix.
    # 
    # Determinate Nix (https://determinate.systems) provides its own Nix daemon
    # and system configuration. When you install Determinate Nix, it:
    # - Installs and manages the standard Nix daemon
    # - Configures /etc/nix/nix.conf with optimized settings
    # - Enables flakes and nix-command by default
    # - Runs Determinate Nixd for additional features (FlakeHub auth, etc.)
    #
    # Setting 'enable = true' here would conflict with Determinate's setup
    # and could cause unexpected behavior. Let Determinate Nix handle the
    # base configuration, and only add specific overrides if needed.
    #
    # Reference: https://docs.determinate.systems/determinate-nix/

    settings.experimental-features = [ "nix-command" "flakes" ];
    # These experimental features are already enabled by Determinate Nix,
    # but we declare them here for clarity and documentation purposes

  };

}
