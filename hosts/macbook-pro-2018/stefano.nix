
# hosts/macbook-pro-2018/stefano.nix
# =============================================================================
# User-specific Home Manager configuration for stefano
# 
# This file defines the personal environment for the user 'stefano', including:
# - User packages and applications
# - Dotfiles and configuration files
# - Environment variables
# - Shell configuration
# =============================================================================

{ pkgs, lib, config, ... }:

let

  # ===========================================================================
  # Convenience Variables
  # ===========================================================================
  
  # XDG Base Directory paths
  # These are standard locations for user configuration and data files
  # See: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
  
  cfgHome = config.xdg.configHome;   # typically "$HOME/.config"
  dataHome = config.xdg.dataHome;     # typically "$HOME/.local/share"
  cacheHome = config.xdg.cacheHome;   # typically "$HOME/.cache"

in

{
  # ===========================================================================
  # Basic Home Configuration
  # ===========================================================================
  
  home = {
    # User identity
    username = "stefano";
    homeDirectory = "/Users/stefano";
    
    # Home Manager state version
    # IMPORTANT: Do NOT change this after initial setup!
    # This ensures compatibility with my existing Home Manager state
    stateVersion = "25.05";
    
    # The stateVersion determines which Home Manager release your config
    # is compatible with. It prevents breaking changes when updating.
    # 
    # This was set when creating the configuration with nixpkgs-unstable
    # in May 2025, which was already tracking the 25.05 release.
  };

  # ===========================================================================
  # XDG Base Directory Specification
  # ===========================================================================
  # 
  # Enable XDG support to ensure applications use standard directories
  # for configuration, data, and cache files
  
  xdg = {
    enable = true;
    
    # We can also configure specific XDG directories if needed:
    # configHome = "${config.home.homeDirectory}/.config";
    # dataHome = "${config.home.homeDirectory}/.local/share";
    # cacheHome = "${config.home.homeDirectory}/.cache";
    # stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # ===========================================================================
  # Program Configurations
  # ===========================================================================
  
  programs = {
    # ---------------------------------------------------------------------------
    # Direnv - Automatic environment switching
    # ---------------------------------------------------------------------------
    # 
    # Direnv automatically loads .envrc files when you enter a directory,
    # perfect for project-specific development environments
    
    direnv = {
      enable = false;
      
      # Integration with Nix for flake-based projects
      # This allows 'use flake' in .envrc files
      nix-direnv.enable = true;
      
      # Additional direnv configuration options:
      # config = {
      #   global = {
      #     load_dotenv = true;  # Also load .env files
      #     strict_env = true;   # Fail on unset variables
      #   };
      # };
      
      # Enable shell integration (bash, zsh, fish)
      # This is handled automatically when the shell is managed by Home Manager
    };
    
    # ---------------------------------------------------------------------------
    # Git - Version control
    # ---------------------------------------------------------------------------
    # Uncomment and configure if we want Home Manager to manage git config
    
    # git = {
    #   enable = true;
    #   userName = "Stefano";
    #   userEmail = "your-email@example.com";
    #   
    #   # Git aliases
    #   aliases = {
    #     st = "status";
    #     co = "checkout";
    #     br = "branch";
    #   };
    #   
    #   # Extra configuration
    #   extraConfig = {
    #     init.defaultBranch = "main";
    #     push.autoSetupRemote = true;
    #   };
    # };
    
    # ---------------------------------------------------------------------------
    # Shell configuration
    # ---------------------------------------------------------------------------
    # Configure our preferred shell (bash, zsh, fish)
    
    zsh = {
      enable = true;
    #   
    #   # Shell aliases
    #   shellAliases = {
    #     ll = "ls -l";
    #     la = "ls -la";
    #     ".." = "cd ..";
    };

    #   # Oh My Zsh integration
    #   oh-my-zsh = {
    #     enable = true;
    #     theme = "robbyrussell";
    #     plugins = [ "git" "macos" "docker" ];
    #   };
    # };

  };

  # ===========================================================================
  # Home Activation Scripts
  # ===========================================================================
  # 
  # These scripts run when Home Manager activates our configuration.
  # They're useful for one-time setup tasks or creating initial config files.
  
  home.activation = {
    # Example: Create initial configurations
    # setupCustomTool = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   if [ ! -d "${cfgHome}/my-tool" ]; then
    #     echo "Setting up my-tool configuration..."
    #     mkdir -p "${cfgHome}/my-tool"
    #     # Additional setup commands...
    #   fi
    # '';
  };

  # ===========================================================================
  # User Packages
  # ===========================================================================
  # 
  # Packages installed only for this user (not system-wide)
  # These will be available in ~/.nix-profile/bin/
  
  # home.packages = with pkgs; [
  #   # Development tools
  #   httpie
  #   jq
  #   
  #   # Productivity
  #   obsidian
  #   
  #   # Utilities
  #   tree
  #   htop
  # ];

  # ===========================================================================
  # Environment Variables
  # ===========================================================================
  # 
  # User-specific environment variables
  
  home.sessionVariables = {
  #   EDITOR = "vim";
  #   BROWSER = "firefox";
  #   PAGER = "less";
  };

  # ===========================================================================
  # File Management
  # ===========================================================================
  # 
  # Home Manager can manage dotfiles by creating symlinks
  
  home.file = {
  #   # Example: Create a custom config file
  #   ".custom-app-rc".text = ''
  #     # Custom app configuration
  #     setting1 = true
  #     setting2 = "value"
  #   '';
  #   
  #   # Example: Copy a file from the nix store
  #   ".config/app/config.json".source = ./configs/app-config.json;
  };

  # ===========================================================================
  # macOS-Specific Settings
  # ===========================================================================
  # 
  # Configure macOS-specific options for this user
  
  targets.darwin = {
  #   # User-level macOS defaults

    defaults = {

      "com.apple.finder" = {
        ShowPathbar = true;
        ShowStatusBar = true;
      };

    };

  };

}
