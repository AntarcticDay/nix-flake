
# hosts/macbook-pro-2018/home-manager.nix
# =============================================================================
# Home Manager integration for this host
# 
# This file configures how Home Manager is integrated into the system and
# defines user accounts. Home Manager allows declarative management of user
# environments, including dotfiles, packages, and services.
# =============================================================================

{ lib, ... }:

{
  # ===========================================================================
  # User Account Definition
  # ===========================================================================
  # 
  # Define the system user account that will be managed by Home Manager.
  # This creates the user in the Darwin system if it doesn't already exist.
  
  users.users.stefano = {
    # User's login name
    # This is what he use to log in and what appears in terminal prompts
    name = "stefano";
    
    # User's home directory path
    # lib.mkDefault allows this to be overridden if needed
    home = lib.mkDefault "/Users/stefano";
    
    # Note: On macOS, users are typically created through System Preferences,
    # so this mainly ensures the user configuration is known to nix-darwin
  };

  # ===========================================================================
  # Home Manager Configuration
  # ===========================================================================
  # 
  # Configure how Home Manager integrates with the Darwin system
  
  home-manager = {
    # Use the same nixpkgs instance as the system
    # This ensures consistency between system and user packages
    useGlobalPkgs = true;
    
    # Install user packages to the user's profile
    # When true, packages are available via `home.packages`
    # When false, they would need to be in `users.<name>.packages`
    useUserPackages = true;
    
    # User-specific Home Manager configuration
    # Each user gets their own Home Manager configuration file
    users.stefano = import ./stefano.nix;
  
    # backupFileExtension = "backup";
    # # Extension for backed up files when Home Manager replaces existing files
  
    verbose = true;
    # Enable verbose output during Home Manager activation
  
    extraSpecialArgs = { };
    # # Extra arguments passed to all Home Manager modules
  };

}

# ===========================================================================
# Notes on Home Manager Integration
# ===========================================================================
# 
# Home Manager can manage:
# - User packages (installed to ~/.nix-profile)
# - Dotfiles (symlinked from the Nix store)
# - User services (launchd agents on macOS)
# - Shell configuration (bash, zsh, fish)
# - Application settings
# 
# The actual user configuration is in ./stefano.nix
# 
# To apply changes:
# $ darwin-rebuild switch --flake .#macbook-pro-2018
# 
# This will:
# 1. Build the Darwin system configuration
# 2. Activate system-wide changes
# 3. Run Home Manager to configure the user environment
# 
# =============================================================================
# References
# =============================================================================
# 
# - Home Manager manual: https://nix-community.github.io/home-manager/
# - nix-darwin manual: https://daiderd.com/nix-darwin/manual/
#
# =============================================================================
