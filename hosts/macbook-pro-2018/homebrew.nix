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
    # These settings control what happens when you run `darwin-rebuild switch`.
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
      # Shell utilities
      "watch"        # Execute a program periodically and show output
      
      # Development dependencies
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
    # Organized by category for easier navigation.
    
    casks = [
      # ---------------------------------------------------------------------------
      # 📱 Communication & Collaboration
      # ---------------------------------------------------------------------------
      
      # Instant messaging and video calls
      "discord"              # Gaming and community chat
      "microsoft-teams"      # Business collaboration
      "zoom"                 # Video conferencing
      "telegram"             # Secure messaging
      "whatsapp"             # WhatsApp desktop client
      # "skype"              # Classic video calling (legacy)
      
      # Remote access
      "teamviewer"           # Remote desktop and support
      
      # Email clients
      "thunderbird"          # Open-source email client
      "tuta-mail"            # Encrypted email service
      
      # ---------------------------------------------------------------------------
      # 🌐 Web Browsers
      # ---------------------------------------------------------------------------
      
      # Main browsers
      "arc"                  # Modern browser with spaces
      "brave-browser"        # Privacy-focused browser
      "brave-browser@beta"   # Brave beta channel
      "chromium"             # Open-source Chrome
      "firefox"              # Mozilla Firefox
      "google-chrome"        # Google Chrome
      "orion"                # WebKit browser with Chrome/Firefox extensions
      "vivaldi"              # Customizable browser
      "zen"                  # Privacy-focused browser based on Firefox
      
      # Browser utilities
      "webcatalog"           # Turn websites into desktop apps
      # "browserosaurus"     # Browser picker tool
      
      # ---------------------------------------------------------------------------
      # ☁️ Cloud Storage & Backup
      # ---------------------------------------------------------------------------
      
      # Backup solutions
      "carbon-copy-cloner"   # Bootable backup creation
      
      # Cloud storage services
      "dropbox"              # Popular cloud storage
      "megasync"             # MEGA cloud storage client
      "omnipresence"         # OmniGroup sync service
      "onedrive"             # Microsoft OneDrive
      
      # ---------------------------------------------------------------------------
      # 📄 Office & Productivity
      # ---------------------------------------------------------------------------
      
      # Microsoft Office suite
      "microsoft-auto-update"  # Keep Office apps updated
      "microsoft-excel"        # Spreadsheet application
      "microsoft-powerpoint"   # Presentation software
      "microsoft-word"         # Word processor
      # "microsoft-onenote"    # Note-taking (use native app)
      # "microsoft-outlook"    # Email client
      
      # Productivity tools
      "fantastical"          # Calendar and reminders
      "raindropio"           # Bookmark manager
      # "deepl"              # Translation tool
      # "updf"               # PDF editor (paid)
      
      # ---------------------------------------------------------------------------
      # 📝 Writing, Notes & Research
      # ---------------------------------------------------------------------------
      
      # Knowledge management
      "logseq"               # Privacy-first knowledge base
      "obsidian"             # Markdown-based note-taking
      "devonthink"           # Document and information manager
      # "anytype"            # Local-first knowledge base
      
      # Learning tools
      "anki"                 # Spaced repetition flashcards
      "mochi"                # Study notes and flashcards
      
      # Academic tools
      "zotero"               # Reference management
      # "bibdesk"            # Bibliography manager
      # "latexit"            # LaTeX equation editor
      # "tex-live-utility"   # TeX distribution manager
      
      # Writing software
      "scrivener"            # Long-form writing tool
      
      # E-books
      "calibre"              # E-book library management
      
      # ---------------------------------------------------------------------------
      # 👨‍💻 Development Tools
      # ---------------------------------------------------------------------------
      
      # Terminal emulators
      "ghostty"              # Modern terminal by Mitchell Hashimoto
      
      # Code editors and IDEs
      "vscodium"             # VS Code without Microsoft telemetry
      "zed"                  # High-performance code editor
      # "coteditor"          # macOS native text editor
      # "emacs"              # Extensible text editor
      
      # ---------------------------------------------------------------------------
      # 🎨 Design & Creativity
      # ---------------------------------------------------------------------------
      
      "adobe-creative-cloud"  # Adobe CC suite manager
      
      # ---------------------------------------------------------------------------
      # 🛠️ System Utilities
      # ---------------------------------------------------------------------------
      
      # System enhancement
      "alfred"               # Productivity launcher (replaces Spotlight)
      "bartender"            # Menu bar organizer
      "hyperkey"             # Caps Lock → Hyper key
      "stats"                # System monitor in menu bar
      
      # File management
      "apparency"            # Detailed app information viewer
      "appcleaner"           # Uninstall apps completely
      "suspicious-package"   # Inspect macOS installer packages
      "the-unarchiver"       # Archive extraction tool
      # "omnidisksweeper"    # Disk space analyzer
      
      # Productivity utilities
      "clipbook"             # Clipboard manager
      # "cheatsheet"         # Show keyboard shortcuts
      # "textsniper"         # OCR tool (extract text from images)
      
      # System maintenance
      "macupdater"           # Track app updates
      # "applite"            # Homebrew GUI
      
      # ---------------------------------------------------------------------------
      # 🖱️ Device Management
      # ---------------------------------------------------------------------------
      
      # Peripheral software
      "logi-options+"        # Logitech device manager (new version)
      # "logitech-options"   # Legacy Logitech software
      # "logitech-g-hub"     # Logitech gaming peripherals
      # "bose-updater"       # Bose device firmware updates
      
      # ---------------------------------------------------------------------------
      # 🔒 Security & Privacy
      # ---------------------------------------------------------------------------
      
      # Encryption
      "cryptomator"          # Cloud storage encryption
      
      # VPN clients (commented - choose one)
      # "protonvpn"          # ProtonVPN client
      # "surfeasy-vpn"       # SurfEasy VPN
      
      # ---------------------------------------------------------------------------
      # 💰 Finance & Cryptocurrency
      # ---------------------------------------------------------------------------
      
      # Portfolio management
      "portfolioperformance"  # Investment portfolio tracker
      
      # Hardware wallets
      "ledger-live"          # Ledger hardware wallet
      "trezor-suite"         # Trezor hardware wallet
      
      # ---------------------------------------------------------------------------
      # 🎬 Media & Downloads
      # ---------------------------------------------------------------------------
      
      # Media players
      "vlc"                  # Versatile media player
      # "iina"               # Modern macOS media player
      
      # Download tools
      "clipgrab"             # Video downloader
      "transmission"         # BitTorrent client
      
      # ---------------------------------------------------------------------------
      # 🎮 Gaming
      # ---------------------------------------------------------------------------
      
      # Game launchers
      "gog-galaxy"           # GOG.com game launcher
      "steam"                # Steam gaming platform
      
      # Games
      "minecraft"            # Minecraft Java Edition
      # "0-ad"               # Historical RTS game
      # "luanti"             # Minecraft-like game (formerly Minetest)
      # "osu"                # Rhythm game
      
      # Cloud gaming
      "nvidia-geforce-now"   # Cloud gaming service
      
      # Emulation
      "openemu"              # Multi-system game emulator
      
      # ---------------------------------------------------------------------------
      # 💻 Virtualization
      # ---------------------------------------------------------------------------
      
      "parallels"            # macOS virtualization (Intel Macs)
      "parallels-toolbox"    # Parallels utilities
      
      # ---------------------------------------------------------------------------
      # 🔤 Fonts
      # ---------------------------------------------------------------------------
      
      # iA Writer font family (excellent for writing)
      "font-ia-writer-duo"     # Duospace variant
      "font-ia-writer-mono"    # Monospace variant
      "font-ia-writer-quattro" # Serif variant
    ];

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
    
    masApps = {
      # ---------------------------------------------------------------------------
      # 📱 Communication
      # ---------------------------------------------------------------------------
      
      "Airmail - Lightning Fast Email"       = 918858936;
      # "BlueMail - Email & Calendar"       = 1458754578;
      
      # ---------------------------------------------------------------------------
      # 📋 Productivity
      # ---------------------------------------------------------------------------
      
      "Daylite"                              = 965269916;   # CRM for macOS
      "Things 3"                             = 904280696;   # Task manager
      "UPDF 2 - Editor PDF AI"               = 1619925971;  # PDF editor
      "Numbers"                              = 409203825;   # Apple spreadsheet
      "Pages"                                = 409201541;   # Apple word processor
      # "Keynote"                            = 409183694;   # Apple presentations
      # "Deliveries: a package tracker"      = 290986013;   # Package tracking
      # "LanguageTool - Grammar-Checker"     = 1534275760;  # Grammar checker
      # "Save to Raindrop.io"                = 1549370672;  # Raindrop extension
      
      # ---------------------------------------------------------------------------
      # 📝 Writing & Notes  
      # ---------------------------------------------------------------------------
      
      "Day One"                              = 1055511498;  # Journal app
      "FSNotes"                              = 1277179284;  # Notes manager
      "iA Writer"                            = 775737590;   # Focused writing
      # "Spreeder VIP - Desktop"             = 1556368936;  # Speed reading
      
      # ---------------------------------------------------------------------------
      # 💻 Development
      # ---------------------------------------------------------------------------
      
      "Xcode"                                = 497799835;   # Apple dev tools
      # "TestFlight"                         = 899247664;   # Beta testing
      
      # ---------------------------------------------------------------------------
      # 🛠️ Utilities
      # ---------------------------------------------------------------------------
      
      "Amphetamine"                          = 937984704;   # Keep Mac awake
      "Magnet"                               = 441258766;   # Window manager
      "The Unarchiver"                       = 425424353;   # Archive utility
      "Unsplash Wallpapers"                  = 1284863847;  # Wallpaper app
      "TextSniper - OCR, Copy & Paste"       = 1528890965;  # OCR tool
      # "Blackmagic Disk Speed Test"         = 425264550;   # Disk benchmark
      # "StopTheMadness"                     = 1376402589;  # Web annoyances
      
      # ---------------------------------------------------------------------------
      # 🖨️ Device Support
      # ---------------------------------------------------------------------------
      
      "Brother iPrint&Scan"                  = 1193539993;  # Brother printers
      
      # ---------------------------------------------------------------------------
      # 🔐 Security
      # ---------------------------------------------------------------------------
      
      "Bitwarden"                            = 1352778147;  # Password manager
      "Encrypto: Secure Your Files"          = 935235287;   # File encryption
      
      # ---------------------------------------------------------------------------
      # 📚 Media & Reading
      # ---------------------------------------------------------------------------
      
      "Amazon Kindle"                        = 302584613;   # E-book reader
      "Reeder Classic."                      = 1529448980;  # RSS reader
      # "Kindle Classic"                     = 405399194;   # Old Kindle app
      
      # ---------------------------------------------------------------------------
      # 🎥 Media Production (commented)
      # ---------------------------------------------------------------------------
      
      # "Blackmagic RAW Player"              = 1435415804;  # RAW video player
      # "Blackmagic RAW Speed Test"          = 1466185689;  # Performance test
      # "DaVinci Resolve"                    = 571213070;   # Video editor
      # "GarageBand"                         = 682658836;   # Music creation
      # "iMovie"                             = 408981434;   # Video editor

      # ---------------------------------------------------------------------------
      # Other (commented)
      # ---------------------------------------------------------------------------

      # "goldenRATIO - The tool for every designer and developer." = 485258055;

    };
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
# **Organization tips:**
# - Keep packages alphabetically sorted within categories
# - Comment out packages you might want later instead of deleting
# - Add comments for packages with special requirements
