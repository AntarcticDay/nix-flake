
# modules/home-manager/default.nix
# =============================================================================
# Home Manager Base Configuration Module
# 
# This module provides the foundational settings for Home Manager integration
# with nix-darwin. It ensures Home Manager works efficiently and consistently
# across all your systems.
#
# What is Home Manager?
# - A tool for managing user-specific configurations declaratively
# - Manages dotfiles, user packages, and user services
# - Works alongside system configuration (nix-darwin/NixOS)
# - Each user gets their own separate configuration
#
# This file sets defaults that apply to ALL users managed by Home Manager.
# Individual user configurations are in /hosts/*/username.nix
# =============================================================================

{ lib, config, pkgs, ... }:

{
  # ===========================================================================
  # Home Manager Global Settings
  # ===========================================================================
  # 
  # These settings control how Home Manager integrates with the system
  # and how it manages user configurations.
  
  home-manager = {
    
    # ---------------------------------------------------------------------------
    # Package Management Settings
    # ---------------------------------------------------------------------------
    
    # Use the same nixpkgs instance as the system
    # 
    # What this means:
    # - Home Manager will use the exact same package set as your system
    # - No duplicate package downloads or builds
    # - Consistent package versions between system and user
    # - Faster evaluation times
    #
    # When false, Home Manager would use its own nixpkgs, potentially
    # downloading packages twice and using different versions
    useGlobalPkgs = true;
    
    # Install user packages to the user's package set
    # 
    # What this means:
    # - User packages go in `home.packages` in user config files
    # - Cleaner separation between system and user packages
    # - Each user's packages are isolated from others
    #
    # When false, you'd need to use `users.users.<name>.packages` instead,
    # mixing user and system configuration
    useUserPackages = true;
    
    # ---------------------------------------------------------------------------
    # Optional: Backup Settings
    # ---------------------------------------------------------------------------
    
    # # File backup extension when Home Manager replaces existing files
    # # 
    # # When Home Manager manages a file that already exists, it creates
    # # a backup with this extension. Default is "backup"
    # # 
    # # Example: If managing ~/.zshrc, existing file becomes ~/.zshrc.backup
    # backupFileExtension = "backup";
    
    # # You can also disable backups entirely (use with caution!)
    # # This will overwrite existing files without creating backups
    # # enableBackupFiles = false;
    
    # ---------------------------------------------------------------------------
    # Optional: Activation Settings
    # ---------------------------------------------------------------------------
    
    # # Verbose output during activation
    # # 
    # # Shows detailed information about what Home Manager is doing
    # # Useful for debugging or understanding the activation process
    verbose = true;
    
    # # Extra activation script
    # # 
    # # Run custom commands during Home Manager activation
    # # This runs AFTER all Home Manager modules have been activated
    # # extraActivationPath = ''
    # #   echo "Home Manager activation complete!"
    # #   # Your custom commands here
    # # '';
    
    # ---------------------------------------------------------------------------
    # Optional: Extra Arguments
    # ---------------------------------------------------------------------------
    
    # # Pass additional arguments to all Home Manager modules
    # # 
    # # These become available in every Home Manager module
    # # Useful for sharing common values or functions
    # extraSpecialArgs = {
    #   # Example: Share a common color scheme
    #   colorScheme = {
    #     base = "#1a1a1a";
    #     accent = "#0080ff";
    #   };
    #   
    #   # Example: Share utility functions
    #   myUtils = {
    #     mkIfElse = cond: yes: no: if cond then yes else no;
    #   };
    # };
    
    # ---------------------------------------------------------------------------
    # Optional: Shared Modules
    # ---------------------------------------------------------------------------
    
    # # Modules to load for ALL users
    # # 
    # # These modules will be imported for every user configuration
    # # Good for enforcing organization-wide policies or shared settings
    # sharedModules = [
    #   # Example: Organization defaults
    #   {
    #     programs.git = {
    #       extraConfig = {
    #         user.company = "ACME Corp";
    #         core.hooksPath = "/opt/acme/git-hooks";
    #       };
    #     };
    #   }
    #   
    #   # Example: Import external module
    #   # ./modules/company-defaults.nix
    # ];
  };

  # ===========================================================================
  # System Integration Settings
  # ===========================================================================
  # 
  # These ensure Home Manager works well with the Darwin system
  
  # Ensure nix-darwin knows about Home Manager's shell completions
  # This makes bash/zsh completions work for Home Manager commands
  environment.pathsToLink = lib.optionals config.home-manager.useUserPackages [
    "/share/bash-completion"
    "/share/zsh"
    "/share/fish"
  ];
  
  # ===========================================================================
  # Optional: System-wide User Defaults
  # ===========================================================================
  # 
  # You can set defaults that apply to all users before Home Manager runs
  # These are lower priority than Home Manager settings
  
  # # Default shell for all users (can be overridden by Home Manager)
  # users.defaultUserShell = pkgs.zsh;
  
  # # Environment variables for all users
  # environment.variables = {
  #   # These are available to all users but can be overridden
  #   ORGANIZATION = "ACME Corp";
  # };
}

# =============================================================================
# How Home Manager Integration Works
# =============================================================================
# 
# 1. **System Build Phase**:
#    - nix-darwin builds the system configuration
#    - Home Manager modules are evaluated but not activated yet
#    - Package sets are prepared
# 
# 2. **Activation Phase**:
#    - System configuration is activated first
#    - Then Home Manager activates each user's configuration
#    - Files are symlinked, services are started
# 
# 3. **User Login**:
#    - User's shell loads Home Manager's environment
#    - User packages become available in PATH
#    - User services start (if configured)
#
# =============================================================================
# File Structure Overview
# =============================================================================
# 
# /modules/home-manager/default.nix (this file)
# └── Provides base Home Manager settings
# 
# /hosts/*/home-manager.nix
# └── Configures which users to manage on that host
# 
# /hosts/*/username.nix
# └── Individual user's Home Manager configuration
#
# =============================================================================
# Common Tasks
# =============================================================================
# 
# **Check Home Manager status:**
# ```bash
# $ home-manager generations
# ```
# 
# **See what files Home Manager manages:**
# ```bash
# $ home-manager files
# ```
# 
# **Manually activate Home Manager changes:**
# ```bash
# $ home-manager switch
# ```
# 
# **Roll back to previous generation:**
# ```bash
# $ home-manager rollback
# ```
