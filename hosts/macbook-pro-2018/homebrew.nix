
# hosts/macbook-pro-2018/homebrew.nix
# Homebrew configuration for this host

{ inputs, ... }:

{
  # nix-homebrew setup
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "stefano";
    mutableTaps = false;
    
    taps = {
      "homebrew/core" = inputs.homebrew-core;
      "homebrew/cask" = inputs.homebrew-cask;
    };
  };

  # Homebrew packages
  homebrew = {
    enable = true;
    
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "zap";
    };

    # CLI tools
    brews = [
                    # "yt-dlp"
                    "watch"
                    "ncurses"
                	  "node"
                    # (= node.js)
    ];

    # GUI applications
    casks = [

                    # ::::::::: Comunicazione e Collaborazione  

                    "discord"
                    "microsoft-teams"
                    # "skype"
                    "zoom"

                    "teamviewer"

                    "telegram"
                    "whatsapp"

                    "thunderbird"
                    "tuta-mail"

                    # ::::::::: Browser e strumenti Web  

                    "arc"
                    "brave-browser"
                    "brave-browser@beta"
                    "chromium"
                    "firefox"
                    "google-chrome"
                    "orion"
                    "vivaldi"
                    "zen"

                    # "browserosaurus"
                    "webcatalog"

                    # ::::::::: Archiviazione Cloud e Backup  

                    "carbon-copy-cloner"

                    "dropbox"
                    "megasync"

                    "omnipresence"
                    "onedrive"

                    # ::::::::: Ufficio e Produttività  

                    # "deepl"

                    "fantastical"

                    "microsoft-auto-update"
                    "microsoft-excel"
                    # "microsoft-onenote"
                    # "microsoft-outlook"
                    "microsoft-powerpoint"
                    "microsoft-word"

                    "raindropio"

                    # "updf"

                    # ::::::::: Scrittura, Note e Ricerca  

                    # "anytype"

                    "logseq"
                    "obsidian"

                    "anki"
                    "mochi"

                    # "bibdesk"
                    # "latexit"
                    # "tex-live-utility"

                    "scrivener"

                    "calibre"

                    "devonthink"

                    "zotero"

                    # ::::::::: Strumenti di Sviluppo  

                    "ghostty"

                    # "emacs"

                    # "coteditor"
                    "vscodium"
                    "zed"

                    # ::::::::: Design e Creatività  

                    "adobe-creative-cloud"

                    # ::::::::: Utility e Strumenti di Sistema  

                    "alfred"
                    "apparency"
                    "appcleaner"
                    # "applite"
                    "bartender"
                    # "cheatsheet"
                    "clipbook"
                    "hyperkey"
                    "macupdater"
                    # "omnidisksweeper"
                    "stats"
                    "suspicious-package"
                    # "textsniper"
                    "the-unarchiver"

                    # ::::::::: Gestione Periferiche  

                    # "bose-updater"

                    "logi-options+"
                    # "logitech-g-hub"
                    # "logitech-options"

                    # ::::::::: Sicurezza e Privacy  

                    "cryptomator"

                    # "protonvpn"
                    # "surfeasy-vpn"

                    # ::::::::: Finanza e Criptovalute

                    "portfolioperformance"

                    "ledger-live"
                    "trezor-suite"

                    # ::::::::: Media e Download

                    # "iina"
                    "vlc"

                    "clipgrab"

                    "transmission"

                    # ::::::::: Giochi

                    "gog-galaxy"
                    "steam"

                    "minecraft"

                    # "0-ad"
                    # "luanti"
                    # "osu"

                    "nvidia-geforce-now"

                    "openemu"

                    # ::::::::: Virtualizzazione

                    "parallels"
                    "parallels-toolbox"

                    # ::::::::: Font  

                    "font-ia-writer-duo"
                    "font-ia-writer-mono"
                    "font-ia-writer-quattro"

    ];

    # Mac App Store apps
    masApps = {

                    # ::::::::: Comunicazione e Collaborazione

                    "Airmail - Lightning Fast Email"     = 918858936;
                    # "BlueMail - Email & Calendar"      = 1458754578;

                    # ::::::::: Ufficio e Produttività

                    "Daylite"                            = 965269916;

                    "Things 3"                           = 904280696;

                    "UPDF 2 - Editor PDF AI"             = 1619925971;

                    # "Deliveries: a package tracker"    = 290986013;

                    # "Keynote"                          = 409183694;

                    # "LanguageTool - Grammar-Checker"   = 1534275760;

                    "Numbers"                          = 409203825;

                    "Pages"                            = 409201541;

                    # "Save to Raindrop.io"              = 1549370672;

                    # ::::::::: Scrittura, Note e Ricerca

                    "Day One"                            = 1055511498;

                    "FSNotes"                            = 1277179284;
                    "iA Writer"                          = 775737590;

                    # "Spreeder VIP - Desktop"           = 1556368936;

                    # ::::::::: Strumenti di Sviluppo

                    "Xcode"                              = 497799835;
                    # "TestFlight"                       = 899247664;

                    # ::::::::: Design e Creatività

                    # "goldenRATIO - The tool for every designer and developer." = 485258055;

                    # ::::::::: Utility e Strumenti di Sistema

                    "Amphetamine"                        = 937984704;
                    "Magnet"                             = 441258766;
                    "The Unarchiver"                     = 425424353;
                    "Unsplash Wallpapers"                = 1284863847;
                    # "Blackmagic Disk Speed Test"       = 425264550;
                    "TextSniper - OCR, Copy & Paste"   = 1528890965;

                    # "StopTheMadness"                   = 1376402589;

                    # ::::::::: Gestione Periferiche

                    "Brother iPrint&Scan"                = 1193539993;

                    # ::::::::: Sicurezza e Privacy

                    "Bitwarden"                          = 1352778147;

                    "Encrypto: Secure Your Files"        = 935235287;

                    # ::::::::: Media e Download

                    "Amazon Kindle"                      = 302584613;
                    # "Kindle Classic"                   = 405399194;

                    "Reeder Classic."                    = 1529448980;

                    # "Blackmagic RAW Player"            = 1435415804;

                    # "Blackmagic RAW Speed Test"        = 1466185689;

                    # "DaVinci Resolve"                  = 571213070;

                    # "GarageBand"                       = 682658836;

                    # "iMovie"                           = 408981434;

    };
  };
}
