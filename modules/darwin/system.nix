
# modules/darwin/system.nix
# =============================================================================
# System-Level Darwin Configuration Module
# 
# This module configures system-wide settings for macOS that apply to all users.
# It handles shells, fonts, and other system preferences that affect the entire
# system.
#
# What this module manages:
# - Available shells and default shell settings
# - System-wide fonts installation
# - Global macOS preferences (optional)
# - System services and daemons (optional)
#
# This configuration applies immediately after `darwin-rebuild switch`.
# =============================================================================

{ pkgs, lib, config, ... }:

{
  # ===========================================================================
  # Shell Configuration
  # ===========================================================================
  # 
  # Configure which shells are available system-wide and their settings.
  # These shells can be used as login shells for users.
  
  programs = {
    # Enable Zsh system-wide
    # 
    # This does several things:
    # - Installs Zsh if not already present
    # - Adds Zsh to /etc/shells (allowed login shells)
    # - Sets up system-wide Zsh configuration in /etc/zshrc
    # - Enables Zsh completions
    zsh.enable = true;
    
    # Other shells:
    bash.enable = true;  # (redundant: bash is always available on macOS)
    # fish.enable = true;  # Fish shell (user-friendly)
  };
  
  # List of shells available for users
  # 
  # These shells will be added to /etc/shells, making them valid login shells.
  # Users can switch to these shells using `chsh -s /path/to/shell`.
  # 
  # Note: The path must be the Nix store path, not /usr/bin or /bin
  environment.shells = with pkgs; [
    zsh       # Z shell - powerful and customizable
    bash      # Bourne Again Shell - standard on most systems
    # fish    # Friendly Interactive Shell
    # nushell # Modern shell with structured data
  ];
  
  # Optional: Set system-wide default shell
  # users.defaultUserShell = pkgs.zsh;

  # ===========================================================================
  # Font Configuration
  # ===========================================================================
  # 
  # Install fonts system-wide so they're available in all applications.
  # On macOS, these fonts are symlinked to ~/Library/Fonts/Nix Fonts/
  
  fonts.packages = with pkgs; [

    # IBM Plex family - IBM's open source typeface
    # Includes Sans, Serif, and Mono variants
    ibm-plex
    
    # Iosevka - Highly customizable programming font
    # Narrow characters, good for code editors with split panes
    iosevka
    
    # JetBrains Mono - Designed for developers by JetBrains
    # Good ligature support and clear at small sizes
    jetbrains-mono
    
    # Lexend - Font family designed to improve reading proficiency
    # Studies show it can significantly improve reading speed
    lexend
    
    # XITS Math - Implementation of STIX fonts for mathematical typesetting
    # Essential for LaTeX and scientific documents
    xits-math
    
    # Atkinson Hyperlegible - Designed for low vision readers
    # Next generation with improved language support
    atkinson-hyperlegible-next
    
    # Atkinson Hyperlegible Mono - Monospace variant
    # Great for coding with vision accessibility needs
    atkinson-hyperlegible-mono

    # --- Icon fonts ---

    # nerdfonts            # Fonts patched with icons
    font-awesome           # Icon font for web

    # --- Additional fonts ---
    # 
    # # Classic programming fonts
    # fira-code              # Popular font with ligatures
    # source-code-pro        # Adobe's coding font
    # cascadia-code          # Microsoft's modern terminal font
    # 
    # # System fonts
    # inter                  # Modern UI font
    # roboto                 # Google's Material Design font
    # noto-fonts             # Google's font family with wide Unicode coverage

  ];
  
  # ===========================================================================
  # Optional: macOS System Preferences
  # ===========================================================================
  # 
  # These settings configure macOS behavior at the system level.
  # They're equivalent to changing settings in System Preferences.
  # 
  # IMPORTANT: Some settings require logout/restart to take effect.
  # 
  # Uncomment and modify the sections you want to manage with Nix:
  
  system.defaults = {
  #   
  #   # ---------------------------------------------------------------------------
  #   # Dock Settings
  #   # ---------------------------------------------------------------------------
  #   # Configure the macOS dock appearance and behavior
  #   
    dock = {
  #     # Automatically hide and show the dock
  #     autohide = true;
  #     
  #     # Delay before showing the dock (in seconds)
  #     autohide-delay = 0.0;
  #     
  #     # Animation time for hiding/showing the dock
  #     autohide-time-modifier = 0.5;
  #     
  #     # Show recent applications in the dock
  #     show-recents = false;
  #     
  #     # Size of dock icons (16-128)
  #     tilesize = 48;
  #     
  #     # Position on screen: "left", "bottom", "right"
  #     orientation = "bottom";
  #     
  #     # Minimize windows using: "genie", "scale"
  #     mineffect = "genie";
  #     
  #     # Enable spring loading for all dock items
  #     enable-spring-load-actions-on-all-items = true;

    };

  #   # ---------------------------------------------------------------------------
  #   # Finder Settings
  #   # ---------------------------------------------------------------------------
  #   # Configure Finder behavior and appearance
  #   
    finder = {
  #     # Show all file extensions
  #     AppleShowAllExtensions = true;
  #     
  #     # Show hidden files
  #     AppleShowAllFiles = true;
  #     
  #     # Show path bar at bottom of Finder windows
  #     ShowPathbar = true;
  #     
  #     # Show status bar with item count and disk space
  #     ShowStatusBar = true;
  #     
  #     # Default Finder view: "icnv" (icon), "list" (list), "clmv" (column), "Flwv" (gallery)
  #     FXPreferredViewStyle = "list";

    # Search scope: "SCcf" (current folder), "SCsp" (previous scope), "SCev" (entire volume)
      FXDefaultSearchScope = "SCcf";

  #     # Warning before changing file extension
  #     FXEnableExtensionChangeWarning = false;
  #     
  #     # Warning before emptying trash
  #     WarnOnEmptyTrash = true;
    };

  #   # ---------------------------------------------------------------------------
  #   # Global macOS Settings
  #   # ---------------------------------------------------------------------------
  #   # System-wide preferences that affect all applications
  #   
    NSGlobalDomain = {
  #     # Enable full keyboard access (tab through all controls)
  #     AppleKeyboardUIMode = 3;
  #     
  #     # Disable press-and-hold for keys in favor of key repeat
  #     ApplePressAndHoldEnabled = false;
  #     
  #     # Key repeat rate (lower = faster)
  #     KeyRepeat = 2;
  #     
  #     # Delay before key repeat starts
  #     InitialKeyRepeat = 15;
  #     
  #     # Enable subpixel font rendering on non-Apple displays
  #     AppleFontSmoothing = 2;
  #     
  #     # Dark mode
  #     AppleInterfaceStyle = "Dark";
  #     
  #     # Show scrollbars: "WhenScrolling", "Automatic", "Always"
  #     AppleShowScrollBars = "WhenScrolling";
  #     
  #     # Natural scrolling direction
  #     "com.apple.swipescrolldirection" = true;
  #     
  #     # Text correction
  #     NSAutomaticSpellingCorrectionEnabled = false;
  #     NSAutomaticCapitalizationEnabled = false;
  #     NSAutomaticPeriodSubstitutionEnabled = false;
  #     NSAutomaticQuoteSubstitutionEnabled = false;
    };
  #   
  #   # ---------------------------------------------------------------------------
  #   # Screenshots
  #   # ---------------------------------------------------------------------------
  #   
    screencapture = {
  #     # Location where screenshots are saved
  #     location = "~/Desktop";
  #     
  #     # Screenshot file type: "png", "jpg", "gif", "pdf"
  #     type = "png";
  #     
  #     # Disable shadow in screenshots
  #     disable-shadow = false;
    };
  #   
  #   # ---------------------------------------------------------------------------
  #   # Trackpad Settings
  #   # ---------------------------------------------------------------------------
  #   
    trackpad = {
  #     # Enable tap to click
  #     Clicking = true;
  #     
  #     # Enable drag lock
  #     Dragging = true;
  #     
  #     # Three finger drag
  #     TrackpadThreeFingerDrag = true;
    };

  };
  
  # ===========================================================================
  # Optional: System Services
  # ===========================================================================
  # 
  # Enable additional system services or daemons
  
  services = {
  #   # Enable the locate database for fast file searching with `locate` command
  #   locate = {
  #     enable = true;
  #     interval = "daily";  # How often to update the database
  #   };
  #   
  #   # Enable the Nix garbage collector
  #   nix-gc = {
  #     enable = true;
  #     interval = "weekly";
  #     options = "--delete-older-than 30d";
  #   };
  };
  
  # ===========================================================================
  # Optional: Environment Variables
  # ===========================================================================
  # 
  # Set system-wide environment variables
  
  environment.variables = {
  #   # Example: Set default editor
  #   EDITOR = "nvim";
  #   
  #   # Example: Custom paths
  #   MY_CUSTOM_PATH = "/opt/custom/bin";
  };
  
  # ===========================================================================
  # Optional: System Packages
  # ===========================================================================
  # 
  # You can also install system-wide packages here, but it's better
  # to use the dedicated packages.nix file for clarity
  
  # environment.systemPackages = with pkgs; [
  #   # System utilities
  #   coreutils
  #   findutils
  #   gnugrep
  # ];

}

# =============================================================================
# Usage Notes
# =============================================================================
# 
# **Applying Changes:**
# ```bash
# $ darwin-rebuild switch --flake .#macbook-pro-2018
# ```
# 
# **Some changes require additional steps:**
# - Dock changes: Kill the Dock process: `killall Dock`
# - Finder changes: Kill Finder: `killall Finder`
# - Font changes: May need to restart applications
# - Shell changes: Start a new terminal session
# 
# **Checking Current Settings:**
# ```bash
# # Read a specific default
# $ defaults read com.apple.dock autohide
# 
# # List all defaults for a domain
# $ defaults read com.apple.finder
# ```
# 
# **Finding Setting Names:**
# 1. Note current setting: `defaults read > before.txt`
# 2. Change setting in System Preferences
# 3. Compare: `defaults read > after.txt && diff before.txt after.txt`
#
# =============================================================================
# References
# =============================================================================
# 
# - nix-darwin options: https://daiderd.com/nix-darwin/manual/index.html
# - macOS defaults: https://macos-defaults.com/
# - Font packages: https://search.nixos.org/packages?query=font
#
# =============================================================================
