# hosts/macbook-pro-2018/homebrew/casks.nix
# List of GUI apps (casks) for this host. Keep it alphabetized within sections.

[
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

      # GitHub Desktop
      "github"               # Desktop client for GitHub repositories

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

]
