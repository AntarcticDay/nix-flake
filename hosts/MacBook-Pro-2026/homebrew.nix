# hosts/MacBook-Pro-2026/homebrew.nix
# =============================================================================
# Homebrew configuration for MacBook Pro 2026 (aarch64-darwin)
#
# This file manages Homebrew packages at the HOST level, combining:
# - System-wide packages (defined here)
# - User-specific packages (imported from users/*/homebrew/)
#
# Structure:
# - System brews: CLI tools available to all users
# - User brews: Imported from ./users/stefano/homebrew/brew.nix
# - User casks: Imported from ./users/stefano/homebrew/cask.nix
# - User mas apps: Imported from ./users/stefano/homebrew/mas.nix
#
# IMPORTANT - two distinct modules are configured below:
# - `nix-homebrew` (from the nix-homebrew input): installs and owns the
#   Homebrew prefix itself, and manages Homebrew's own trust store.
# - `homebrew`     (from the nix-darwin input): generates a Brewfile and runs
#   `brew bundle` during activation to install taps/formulae/casks.
# Options belong to one module or the other and are NOT interchangeable.
# =============================================================================

{ inputs, lib, ... }:

let
  # Import user-specific Homebrew lists
  # These are now organized per-user for better modularity
  userBrews = import ./users/stefano/homebrew/brew.nix;
  userCasks = import ./users/stefano/homebrew/cask.nix;
  userMasApps = import ./users/stefano/homebrew/mas.nix;

  # System-wide CLI tools
  # These are available to all users on this host
  systemBrews = [
    # "watch"        # Execute a program periodically and show output
    # "ncurses"      # Terminal control library
    # "node"         # Node.js JavaScript runtime
    # "ungit"        # Git UI
    # "forgejo"      # Self-hosted forge
    # "fastfetch"    # System info fetcher
  ];
in
{
  # ===========================================================================
  # nix-homebrew Configuration
  #
  # Installs and owns the Homebrew prefix. Provided by the `nix-homebrew`
  # flake input, NOT by nix-darwin.
  # ===========================================================================

  nix-homebrew = {
    enable = true;
    enableRosetta = true;    # Apple Silicon: also install under the Intel prefix

    user = "stefano";

    # Ensure the Homebrew prefix (/usr/local on Intel) exists before taps
    # are added. Without this, tap operations like d12frosted/emacs-plus
    # fail because the /usr/local/Homebrew tree hasn't been bootstrapped.
    autoMigrate = true;

    # Use mutable taps - Homebrew manages its own repositories
    # This avoids issues with immutable Nix store paths
    mutableTaps = true;

    # We don't specify taps here when using mutableTaps
    # They will be managed by Homebrew itself

    patchBrew = true;

    # -------------------------------------------------------------------------
    # Declarative tap trust (Homebrew 6.0.0)
    #
    # Since Homebrew 6.0.0, non-official taps must be explicitly trusted before
    # Homebrew will evaluate their Ruby code; untrusted items are refused or
    # silently skipped by `brew bundle`. `nix-homebrew.trust` writes entries
    # into Homebrew's own trust store, so they apply to every brew invocation,
    # including the one performed during system activation.
    #
    # DISABLED FOR NOW: this option only exists in recent nix-homebrew releases.
    # Check whether the currently locked revision provides it with:
    #
    #   grep -rn "trust" "$(nix eval --raw ~/nix/flake#inputs.nix-homebrew.outPath)/modules/"
    #
    # If it returns nothing, run `nix flake update nix-homebrew` first.
    # Until then, trust is granted once, imperatively (see the note at the
    # bottom of this file).
    #
    # WARNING: removing an entry from these lists does NOT revoke the trust.
    # Use `brew untrust <name>` to actually remove it.
    # -------------------------------------------------------------------------
    # trust = {
    #   # Per-item trust is preferable to trusting a whole tap, which would mean
    #   # accepting all of its current AND future formulae and casks.
    #   casks = [ "alielsokary/tap/caskhub" ];
    #   formulae = [ "d12frosted/emacs-plus/emacs-plus" ];
    # };
  };

  # ===========================================================================
  # Homebrew Package Configuration
  #
  # Generates the Brewfile and runs `brew bundle` on activation. Provided by
  # nix-darwin.
  # ===========================================================================

  homebrew = {
    enable = true;

    # The official core and cask taps are included by default; only third-party
    # taps go here.
    #
    # NOTE: taps are declared as plain strings. nix-darwin's per-tap `trusted`
    # option (which would emit `trusted: true` in the Brewfile) does not exist
    # in the nix-darwin release currently pinned by this flake, so trust is
    # handled separately (see nix-homebrew.trust above).
    taps = [
      # Emacs Plus. Nothing is installed from this tap through Nix right now
      # (emacs-plus is managed manually as a formula), but the tap is kept
      # declared so `brew upgrade emacs-plus` keeps working.
      "d12frosted/emacs-plus"

      # CaskHub - native SwiftUI GUI for browsing and installing Homebrew casks.
      # MIT licensed and open source. Not available in homebrew-cask: it is
      # published only in the author's own tap. The cask itself ("caskhub") is
      # listed in users/stefano/homebrew/cask.nix.
      "alielsokary/tap"

      # Example of other third-party taps:
      # "homebrew/services"
      # "homebrew/cask-versions"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "none";    # zap / none
    };

    # Combine system-wide and user-specific brews
    brews = systemBrews ++ userBrews;

    # -------------------------------------------------------------------------
    # Deferred: manage Emacs Plus through Nix again. Note that the build options
    # below are only accepted by the `emacs-plus` FORMULA, not by the
    # `emacs-plus-app` cask. Requires the tap to be trusted first.
    # -------------------------------------------------------------------------
    # brews = systemBrews ++ userBrews ++ [
    #   {
    #     name = "emacs-plus";
    #     args = [ "with-dbus" "with-debug" "with-imagemagick" "with-mailutils" "with-xwidgets" ];
    #   }
    # ];

    # User-specific casks
    casks = userCasks;

    # User-specific Mac App Store apps
    masApps = userMasApps;
  };

  # ===========================================================================
  # One-time manual setup required on this host
  # ===========================================================================
  #
  #   brew tap alielsokary/tap
  #   brew trust --cask alielsokary/tap/caskhub
  #
  # This grants Homebrew 6 tap trust imperatively. It persists on the machine
  # and only needs to be done once. Replace it with the declarative
  # `nix-homebrew.trust` block above once the input has been updated.
  # ===========================================================================
}
