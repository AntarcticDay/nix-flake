
# modules/darwin/homebrew.nix
# =============================================================================
# Homebrew Base Configuration Module
#
# This module provides the default configuration for Homebrew integration
# with nix-darwin. It sets sensible defaults that can be overridden by
# individual host configurations.
#
# =============================================================================

{ inputs, lib, config, ... }:

{
  # ===========================================================================
  # Homebrew Activation Settings
  # ===========================================================================
  #
  # These settings control how Homebrew behaves during system activation
  # (when you run `darwin-rebuild switch`). They ensure predictable,
  # idempotent behavior - running the same command multiple times
  # produces the same result.

  homebrew = lib.mkIf config.homebrew.enable {
    # The onActivation settings control brew bundle behavior
    # These are the defaults that keep Homebrew predictable and fast

    onActivation = lib.mkDefault {
      # ---------------------------------------------------------------------------
      # Auto-update Setting
      # ---------------------------------------------------------------------------
      #
      # Whether to run `brew update` before installing
      #
      # Why we set it to false:
      # - Homebrew stores its repos in the Nix store (read-only)
      # - Git operations in read-only directories would fail
      # - Updates should be done through updating flake inputs instead
      # - Keeps activation fast and predictable
      #
      # To update Homebrew formulas:
      # 1. Update flake inputs: `nix flake update`
      # 2. Then rebuild: `darwin-rebuild switch`
      autoUpdate = false;

      # ---------------------------------------------------------------------------
      # Upgrade Setting
      # ---------------------------------------------------------------------------
      #
      # Whether to upgrade already-installed packages
      #
      # Why we set it to true:
      # - Ensures installed packages match your configuration
      # - Updates packages when you change version constraints
      # - Keeps your system in sync with the Brewfile
      #
      # Note: This respects version pinning if you specify versions
      upgrade = true;

      # ---------------------------------------------------------------------------
      # Cleanup Setting
      # ---------------------------------------------------------------------------
      #
      # How to handle packages not listed in your configuration
      #
      # Options:
      # - "none": Don't remove anything (manual management)
      # - "uninstall": Remove unlisted packages (keeps associated files)
      # - "zap": Remove unlisted packages AND their associated files
      #
      # Why we use "zap":
      # - Ensures your system exactly matches your configuration
      # - Removes leftover files (caches, preferences, etc.)
      # - Prevents accumulation of unused files
      # - True declarative management - only configured apps remain
      #
      # WARNING: This will remove any manually installed Homebrew packages!
      # To keep manual packages, either:
      # 1. Add them to your configuration
      # 2. Change this to "none" or "uninstall"
      cleanup = "zap";
    };

    # ===========================================================================
    # Additional Homebrew Settings (Optional)
    # ===========================================================================
    #
    # These settings can be configured per-host but here are the options:

    # # Global Homebrew behavior (when running brew manually)
    # global = {
    #   # Where to install casks (default: /Applications)
    #   # caskdir = "/Applications";
    #
    #   # Environment variables for Homebrew
    #   # env = {
    #   #   HOMEBREW_NO_ANALYTICS = "1";
    #   #   HOMEBREW_NO_INSECURE_REDIRECT = "1";
    #   # };
    # };

    # # Arguments passed to all cask installs
    # caskArgs = {
    #   # Install casks to user's Applications folder
    #   # appdir = "~/Applications";
    #
    #   # Don't quarantine downloaded applications
    #   # no_quarantine = true;
    #
    #   # Additional language packs to install
    #   # language = "en,es,fr";
    # };

    # # Whether to enable Homebrew's auto-update entirely
    # # Different from onActivation.autoUpdate - this affects manual brew commands
    # # autoUpdate = false;
  };
}

# =============================================================================
# How This Module Works
# =============================================================================
#
# 1. **Module Structure**:
#    - This file: Sets default Homebrew behaviors
#    - Host homebrew.nix: Specifies packages and overrides
#    - nix-darwin: Generates Brewfile and runs brew bundle
#
# 2. **The lib.mkIf Pattern**:
#    - Only applies settings if homebrew.enable = true
#    - Prevents errors if Homebrew is disabled
#    - Allows conditional configuration
#
# 3. **The lib.mkDefault Pattern**:
#    - Sets default values that can be overridden
#    - Host configs can change these settings
#    - Priority: host config > this module > Homebrew defaults
#
# =============================================================================
# Homebrew Package Types
# =============================================================================
#
# **Brews** (CLI tools):
# - Command-line programs and libraries
# - Installed to: /opt/homebrew (Apple Silicon) or /usr/local (Intel)
# - Examples: git, wget, node, python
#
# **Casks** (GUI applications):
# - macOS applications with graphical interfaces
# - Installed to: /Applications (or custom location)
# - Examples: firefox, vscode, discord
#
# **Taps** (Formula repositories):
# - Additional package sources beyond homebrew/core
# - Examples: homebrew/cask-versions, user/custom-tap
#
# **Mac App Store (mas)**:
# - Apps from the Mac App Store
# - Requires being signed into the App Store
# - Specified by numeric app ID
#
# =============================================================================
# Troubleshooting
# =============================================================================
#
# **"brew update" fails**:
# - This is expected with autoUpdate = false
# - Update via: `nix flake update` then rebuild
#
# **Package not found**:
# - Search: `brew search packagename`
# - May need to add a tap first
# - Check if it's a cask vs brew
#
# **Manual packages being removed**:
# - Due to cleanup = "zap"
# - Add to configuration or change cleanup setting
#
# **App Store apps not installing**:
# - Must be signed into Mac App Store
# - App must be "purchased" (even if free)
# - Find ID from App Store URL or `mas search`
#
# =============================================================================
# References
# =============================================================================
#
# - Homebrew Bundle: https://github.com/Homebrew/homebrew-bundle
# - nix-darwin Homebrew: https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.enable
# - Finding App Store IDs: https://github.com/mas-cli/mas
#
# =============================================================================

