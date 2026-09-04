# hosts/macbook-pro-2026/users/stefano/homebrew/cask.nix
# =============================================================================
# List of GUI apps (casks) for this host. Keep it alphabetized within sections.
# =============================================================================

[

      # --- Communication & Collaboration ------------------------------------------

      # Instant messaging and video calls
      "discord"                 # Gaming and community chat
      "microsoft-teams"         # Business collaboration
      "zoom"                    # Video conferencing
      "telegram"                # Secure messaging
      "whatsapp"                # WhatsApp desktop client
      # "skype"                 # Classic video calling (legacy)
      # "simplex"                 # Messenger for SimpleX protocol

      # Remote access
      # "teamviewer"            # Remote desktop and support
      # "rustdesk"              # Open source virtual/remote desktop application

      # Email clients
      # "thunderbird"           # Open-source email client
      "thunderbird@esr"         # Mozilla Thunderbird ESR, Mozilla Thunderbird Extended Support Release
      # "tuta-mail"             # Encrypted email service

      # --- Web Browsers -----------------------------------------------------------

      # Main browsers
      # "arc"                   # Modern browser with spaces
      "brave-browser"           # Privacy-focused browser
      # "brave-browser@beta"    # Brave beta channel
      # "chromium"              # Open-source Chrome
      # "firefox"               # Mozilla Firefox
      "firefox@esr"             # Mozilla Firefox ESR, Mozilla Firefox Extended Support Release
      # "google-chrome"         # Google Chrome
      # "orion"                 # WebKit browser with Chrome/Firefox extensions
      "vivaldi"                 # Customizable browser
      "zen"                     # Privacy-focused browser based on Firefox
      "mullvad-browser"         # Privacy browser by Mullvad + the Tor Project.


      # Utilities
      # "webcatalog"            # Turn websites into desktop apps
      # "browserosaurus"        # Browser picker tool
      "localsend"               # Open-source cross-platform alternative to AirDrop

      # --- Cloud Storage & Backup -------------------------------------------------

      # Backup solutions
      # "carbon-copy-cloner"    # Bootable backup creation

      # Cloud storage services
      # "dropbox"               # Popular cloud storage
      # "megasync"              # MEGA cloud storage client
      # "omnipresence"          # OmniGroup sync service
      # "onedrive"              # Microsoft OneDrive

      # --- Office & Productivity --------------------------------------------------

      # Microsoft Office suite
      # "microsoft-auto-update" # Keep Office apps updated
      "microsoft-excel"         # Spreadsheet application
      # "microsoft-powerpoint"  # Presentation software
      "microsoft-word"          # Word processor
      # "microsoft-onenote"     # Note-taking (use native app)
      # "microsoft-outlook"     # Email client

      # Productivity tools
      # "fantastical"           # Calendar and reminders
      # "raindropio"            # Bookmark manager
      # "deepl"                 # Translation tool

      # --- Writing, Notes & Research ----------------------------------------------

      # Knowledge management
      # "anytype"               # Local-first knowledge base
      # "logseq"                # Privacy-first knowledge base
      "obsidian"                # Markdown-based note-taking

      # "devonthink"            # Document and information manager

      # Learning tools
      # "anki"                  # Spaced repetition flashcards
      # "mochi"                 # Study notes and flashcards

      # Academic tools
      # "zotero"                # Reference management
      # "bibdesk"               # Bibliography manager
      # "latexit"               # LaTeX equation editor
      # "tex-live-utility"      # TeX distribution manager

      # Writing software
      # "scrivener"             # Long-form writing tool

      # E-books
      # "calibre"               # E-book library management

      # --- Development ------------------------------------------------------------

      # GitHub Desktop
      # "github"                # Desktop client for GitHub repositories

      #  GitUp
      "gitup-app"               # Git interface focused on visual interaction

      # Code editors and IDEs
      "vscodium"                # VS Code without Microsoft telemetry
      "zed"                     # High-performance code editor
      # "coteditor"             # macOS native text editor
      # "emacs-app"             # Text editor
      # "emacs-plus-app"        # Managed manually via `brew install emacs-plus` (formula, not cask).
                                  # Kept out of Nix because brew bundle can't load the d12frosted/emacs-plus tap (Homebrew 6 tap-trust bug).
      "asciidocfx"              # Asciidoc editor and toolchain to build books, documents and slides

      # --- Design & Creativity --------------------------------------------------------------

      "affinity"              # Image editing and design software
      # "adobe-creative-cloud"  # Adobe CC suite manager
      # "darktable"             # Photography workflow application and raw developer

      # --- Utilities --------------------------------------------------------------

      # Terminal emulators
      "ghostty"                 # Modern terminal by Mitchell Hashimoto

      # System enhancement
      # "alfred"                # Productivity launcher (replaces Spotlight)
      # "bartender"             # Menu bar organizer
      "hyperkey"                # Caps Lock → Hyper key
      "stats"                   # System monitor in menu bar
      "rectangle"               # Move and resize windows using keyboard shortcuts or snap areas

      # File management
      # "apparency"             # Detailed app information viewer
      "appcleaner"            # Uninstall apps completely
      # "suspicious-package"    # Inspect macOS installer packages
      # "the-unarchiver"        # Archive extraction tool - App Store
      # "omnidisksweeper"       # Disk space analyzer

      # Productivity utilities
      "clipbook"                # Clipboard manager
      # "cheatsheet"            # Show keyboard shortcuts
      # "textsniper"            # OCR tool (extract text from images)

      # System maintenance
      # "macupdater"            # Track app updates
      # "applite"               # Homebrew GUI
      "caskhub"                 # Native GUI for Homebrew casks

      # "mactracker"            # Detailed information on every Apple product ever made

      # --- Device Management ------------------------------------------------------

      # Peripheral software

      "openlogi"                # Local-first alternative to Logitech Options+ for HID++ devices
      # "logi-options+"         # Logitech device manager (new version)
      # "logitech-options"      # Legacy Logitech software
      # "logitech-g-hub"        # Logitech gaming peripherals
      # "bose-updater"          # Bose device firmware updates

      # --- Security & Privacy -----------------------------------------------------

      # Encryption
      # "cryptomator"           # Cloud storage encryption

      # VPN clients (commented - choose one)
      # "protonvpn"             # ProtonVPN client
      # "surfeasy-vpn"          # SurfEasy VPN
      "mullvad-vpn"             # Mullvad VPN client.

      # --- Finance & Cryptocurrency -----------------------------------------------

      # Portfolio management
      # "portfolioperformance"  # Investment portfolio tracker

      # Hardware wallets
      # "ledger-wallet"         # Wallet desktop application to maintain multiple cryptocurrencies (formerly ledger-live)
      # "trezor-suite"          # Companion app for the Trezor hardware wallet

      # --- Media & Downloads ------------------------------------------------------

      # Media players
      "vlc"                     # Versatile media player
      # "iina"                  # Modern macOS media player

      # Download tools
      # "clipgrab"              # Video downloader
      "transmission"            # BitTorrent client

      # --- Gaming -----------------------------------------------------------------

      # Game launchers
      # "gog-galaxy"            # GOG.com game launcher
      # "prismlauncher"         # Minecraft launcher
      "steam"                   # Steam gaming platform

      # Games
      "minecraft"               # Minecraft Java Edition
      # "0-ad"                  # Historical RTS game
      # "luanti"                # Minecraft-like game (formerly Minetest)
      # "osu"                   # Rhythm game

      # Cloud gaming
      "nvidia-geforce-now"      # Cloud gaming service

      # Emulation
      # "openemu"               # Multi-system game emulator
      # "pcsx2"                 # Playstation 2 Emulator

      # --- Virtualization ---------------------------------------------------------

      "parallels"               # Desktop virtualization software
      # "parallels-toolbox"     # Parallels utilities

      # --- Fonts ------------------------------------------------------------------

      # iA Writer font family (excellent for writing)
      "font-ia-writer-duo"      # Duospace variant
      "font-ia-writer-mono"     # Monospace variant
      "font-ia-writer-quattro"  # Serif variant

      # Nerd Fonts
      "font-hack-nerd-font"     # Hack Nerd Font (Hack)
      "font-symbols-only-nerd-font" # Symbols Nerd Font (Symbols Only)


      "font-jetbrains-mono"

      "font-six-caps"
      "font-league-gothic"

      # --- Other ------------------------------------------------------------------

      "cloudflare-warp"         # Free app that makes your Internet safer
      "docker-desktop"          # docker-desktop
      "lm-studio"               # Discover, download, and run local LLMs
      "thaw"                    # Menu bar manager
      "comfy"                   # Node-based image, video and audio generator
      "claude"                  # Anthropic's official Claude AI desktop app
      "netnewswire"             # Free and open-source RSS reader
      "rclone"                  # Rsync for cloud storage

]
