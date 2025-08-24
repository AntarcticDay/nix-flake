# hosts/macbook-pro-2018/homebrew.nix
# =============================================================================
# Homebrew configuration for MacBook Pro 2018
# 
# This file specifies which applications to install via Homebrew on this
# specific machine. Homebrew manages:
# - GUI applications (casks) → installed to /Applications
# - CLI tools (brews) → installed to /usr/local (Intel) or /opt/homebrew (ARM)  
# - Mac App Store apps (masApps) → installed via App Store
#
# The packages are organized by category for easier maintenance.
# =============================================================================

{ inputs, ... }:

let

  # I'm keeping big lists in separate files so this file stays readable.
  cask_list  = import ./cask-list.nix;
  mas_list = import ./mas-list.nix;

in

{
  # ===========================================================================
  # nix-homebrew Configuration
  # ===========================================================================
  # 
  # nix-homebrew integrates Homebrew with Nix, allowing declarative management
  # of Homebrew packages through your Nix configuration.
  
  nix-homebrew = {
    # Enable nix-homebrew integration
    enable = true;
    
    # Rosetta emulation for Apple Silicon apps on Intel Macs
    # Set to false since this is an Intel Mac (x86_64)
    enableRosetta = false;
    
    # User who owns the Homebrew installation
    # This user will have write access to Homebrew directories
    user = "stefano";
    
    # Mutable taps: whether Homebrew taps can be modified outside Nix
    # false = Taps are managed declaratively through Nix only
    # true = Allow manual `brew tap` commands (not recommended)
    mutableTaps = false;
    
    # Homebrew taps (package repositories)
    # These are pinned to specific versions via flake inputs for reproducibility
    taps = {
      "homebrew/core" = inputs.homebrew-core;  # CLI tools and libraries
      "homebrew/cask" = inputs.homebrew-cask;  # GUI applications
    };
  };

  # ===========================================================================
  # Homebrew Package Configuration
  # ===========================================================================
  
  homebrew = {
    # Enable Homebrew management through nix-darwin
    enable = true;
    
    # ---------------------------------------------------------------------------
    # Activation Behavior
    # ---------------------------------------------------------------------------
    # 
    # These settings control what happens when we run `darwin-rebuild switch`.
    # The defaults from modules/darwin/homebrew.nix can be overridden here.
    
    onActivation = {
      # Don't auto-update Homebrew formulas (managed via flake inputs)
      autoUpdate = false;
      
      # Upgrade existing packages to match configuration
      upgrade = true;
      
      # Remove packages not in this configuration (including their data)
      # "zap" = remove app AND associated files (caches, preferences, etc.)
      cleanup = "zap";
    };

    # ===========================================================================
    # CLI Tools (brews)
    # ===========================================================================
    # 
    # Command-line tools installed via Homebrew.
    # These complement packages from Nix with macOS-specific tools.
    
    brews = [

      "watch"        # Execute a program periodically and show output

      "ncurses"      # Terminal control library (dependency for some tools)
      "node"         # Node.js JavaScript runtime (includes npm)
      
      # Media tools (commented out - uncomment if needed)
      # "yt-dlp"     # Download videos from YouTube and other sites
    ];

    # ===========================================================================
    # GUI Applications (casks)
    # ===========================================================================
    # 
    # Desktop applications installed to /Applications.
    
    casks = cask_list;

    # ===========================================================================
    # Mac App Store Applications (masApps)
    # ===========================================================================
    # 
    # Apps from the Mac App Store, identified by their numeric ID.
    # You must be signed into the App Store for these to install.
    #
    # To find an app's ID:
    # 1. Open the app's App Store page
    # 2. Look at the URL: apps.apple.com/app/id[NUMBER]
    # 3. Or use: `mas search "app name"`
    
    masApps = mas_list;

  };
}

# =============================================================================
# Usage and Maintenance Notes
# =============================================================================
# 
# **Adding new packages:**
# 1. Find the package: `brew search package-name`
# 2. Add to appropriate section (brews/casks)
# 3. Run: `darwin-rebuild switch --flake .#macbook-pro-2018`
# 
# **Finding Mac App Store IDs:**
# 1. Search: `mas search "App Name"`
# 2. Or copy from App Store URL
# 
# **Troubleshooting:**
# - If a cask fails: check if it needs Rosetta or has architecture limits
# - If mas fails: ensure you're signed into the App Store
# - Run `brew doctor` to diagnose Homebrew issues
#
# =============================================================================
