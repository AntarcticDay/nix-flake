
{     # flake

  ######################################################################
  # Flake inputs (upstream dependencies)
  ######################################################################

  inputs = {     # inputs

    # ======== nixpkgs ==============================================

    # ---------- nixpkgs channels --------------------------------

    nixpkgs-stable.url  = "https://flakehub.com/f/NixOS/nixpkgs/*";     # stable
    # Stable (pinned) channel via FlakeHub, rolling.

    nixpkgs-unstable.url  = "github:NixOS/nixpkgs/nixpkgs-unstable";     # unstable
    # Unstable core channel, rolling, directly from GitHub.

    # ---------- Nixpkgs -----------------------------------------

    nixpkgs.follows = "nixpkgs-unstable";
    # `nixpkgs` input follows the unstable channel

    # ======== OS-level configuration managers ======================

    # ---------- Home Manager ------------------------------------

    # declarative per-user configuration of packages and dotfiles

    homeManager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";   # keeps Home Manager in-sync with our Nix default channel
      };
    };

    # ---------- nix-darwin --------------------------------------

    # macOS system manager

    nix-darwin = {
      url                     = "github:LnL7/nix-darwin";   # master branch
      inputs.nixpkgs.follows  = "nixpkgs";                  # keeps nix-darwin's nixpkgs in-sync with our Nix default channel
    };

    # ---------- Homebrew support (Darwin) -----------------------

    # Homebrew bootstrapper

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      # inputs.nixpkgs.follows = "nixpkgs";   # (superfluous)
    };

    # Upstream Homebrew taps
    # non-flake source

    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };

    # ======== utility ==============================================

    systems.url = "github:nix-systems/default";            # canonical list of system identifiers

    flake-utils.url       = "github:numtide/flake-utils";  # provides helpers such as eachDefaultSystem, simpleFlake, etc.

    treefmt-nix.url   = "github:numtide/treefmt-nix";      # formatter

    flake-schemas.url     = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    # JSON schemas that IDEs can use to validate the flake

   };     # /inputs

  ######################################################################
  # Flake outputs
  ######################################################################

  outputs = inputs@{ 
    self
    , nixpkgs
    , nixpkgs-stable
    , nixpkgs-unstable
    , systems
    , flake-utils
    , flake-schemas
    , nix-darwin
    , homeManager
    , nix-homebrew
    , homebrew-core
    , homebrew-cask
    , ... 
   }:

    ########## let ###########################################

    let     # let


      # Import our library functions
      lib = import ./lib { inherit nixpkgs nixpkgs-stable nixpkgs-unstable; };
      
      # Extract what we need from lib
      inherit (lib) forAllSystems mkPkgs;

      # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      # Basic constants
      # definizioni usate negli output

        # hostname  
        hostname = "macbook-pro-2018";       # machine hostname (used by nix-darwin)

      # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


      # Build outputs for a specific system

      mkSystemOutputs = system: let
        env = mkPkgs system;
        collections = import ./packages/collections.nix { pkgs = env.pkgs; };
      in {
        packages = {
          default = collections.userPackages;
        };
        
        devShells = {
          default = env.pkgs.mkShell {
            packages = collections.devShellPackages;
          };
        };
      };











      # ===================== nix-darwin  (macOS only) ===============

      # Darwin system configuration

      darwinSystem = system: 


        # nix-darwin system configuration
        # build & switch with: `sudo darwin-rebuild switch --flake ~/my-nix`

        let

          env = mkPkgs system;
          pkgs = env.pkgs;
          collections = import ./packages/collections.nix { inherit pkgs; };

        in {

          ${hostname} = nix-darwin.lib.darwinSystem {     # darwinSystem

            inherit system;
            inherit pkgs;     # build the system with the unstable channel

            specialArgs = {
              inherit inputs;
              pkgsStable = env.pkgsStableRaw;
              pkgsUnstable = env.pkgsUnstableRaw;
             };
            # makes additional values available inside modules
            # handy for Home-Manager, etc.

            modules = [     # darwin_modules

              # --------- base ---------------------------------------

              # minimal base that handles users, font dirs, paths, etc.
              nix-darwin.darwinModules.simple

              # --------- inline host-specific configuration ---------

              # could be split into ./configuration.nix

              ({ pkgs, lib, ... }: {

                nix.enable = false;
                # we rely on Determinate Systems' daemon (installed separately), instead of nix-darwin's

                system.primaryUser = "stefano";       # (used by nix-darwin)

                nix.settings.experimental-features = [ "nix-command" "flakes" ];
                # ensures flakes & nix-command are on
                # redundant on Determinate Nix

                # login shells
                programs.zsh.enable   = true;
                environment.shells    = [ pkgs.zsh pkgs.bash ];

                # system-wide packages
                # (global packages, available to every user)
                environment.systemPackages = 
                  collections.base
                  ++ (with pkgs.stable; [
                    taisei
                   ])
                  ++ (with pkgs; [
                    neofetch
                    sillytavern
                   ]);

                # system-wide font
                # (will appear under in /Library/Fonts/Nix Fonts)
                fonts.packages = with pkgs; [
                  ibm-plex
                  iosevka
                  jetbrains-mono
                  lexend
                  xits-math
                  atkinson-hyperlegible-next
                  atkinson-hyperlegible-mono
                 ];

               })

              # --------- Home Manager -------------------------------

              homeManager.darwinModules.home-manager       # nix-darwin module
              # modulo principale di Home Manager per macOS

              ({ pkgs, lib, ... }: {

                users.users.stefano = {
                  name  = "stefano";
                  home  = lib.mkDefault "/Users/stefano";       # absolute path to $HOME
                 };

                home-manager = {       # configurazione di home-manager

                  useGlobalPkgs    = true;   # re-use system pkgs, faster evaluation
                  useUserPackages  = true;   # packages.* available under `home.packages`

                  users.stefano    = import ./home-manager/stefano.nix;

                 };

               })     # /home-manager

              # ========= nix-homebrew ===============================

              nix-homebrew.darwinModules.nix-homebrew {       # nix-darwin module

                nix-homebrew = {     # /nix-homebrew

                  enable = true;            # what?

                  # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                  enableRosetta = false;

                  # User owning the Homebrew prefix
                  user = "stefano";         # proprietario della directory /usr/local

                  # Optional: Enable fully-declarative tap management
                  # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                  mutableTaps = false;         # taps are declarative – no `brew tap` by hand

                  # Optional: Declarative tap management
                  taps = {
                    "homebrew/core" = homebrew-core;
                    "homebrew/cask" = homebrew-cask;
                   };

                 };     # /nix-homebrew

               }       # nix-darwin module

              # ========= Homebrew ===================================

              {     # homebrew_{}
                homebrew = {     # homebrew

                  enable = true;            # what?

                  # Behaviour during darwin-rebuild
                  onActivation = {
                    autoUpdate = false;         # brew update, con false si evita il git pull in nix-store
                    upgrade    = true;          # brew upgrade
                    cleanup    = "zap";         # remove unlisted packages
                   };

                  # --------- Packages to install via Homebrew -----------

                  # CLI formulae
                  # brew install …
                  brews = [
                    # "yt-dlp"
                    "watch"
                    "ncurses"
                	  "node"
                    # (= node.js)
                   ];

                  # apps
                  # brew install --cask …
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

                   ];     # /casks

                  ## Mac App Store apps (needs `mas` via brew)
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

                   };     # /masApps

                 };     # /homebrew

               }     # /homebrew_{}

             ];     # /darwin_modules

           };     # /darwinSystem

         };     # /in

       # /darwin_configuration

     # /let

    in {

      # Multi-system outputs
      packages = forAllSystems (system: (mkSystemOutputs system).packages);
      devShells = forAllSystems (system: (mkSystemOutputs system).devShells);
      
      # Darwin configurations
      darwinConfigurations = darwinSystem "x86_64-darwin";
      
      # Schemas for validation
      # schemas = flake-schemas.schemas;

    };

   # /outputs

 }     # /flake
