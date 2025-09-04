
# hosts/macbook-pro-2018/home-manager.nix
# =============================================================================
# Home Manager integration for this host
# 
# This file configures how Home Manager is integrated into the system and
# defines user accounts. Home Manager allows declarative management of user
# environments, including dotfiles, packages, and services.
# =============================================================================

{ config, lib, pkgs, ... }:

{
  # ===========================================================================
  # User Account Definition
  # ===========================================================================
  # 
  # Define the system user account that will be managed by Home Manager.
  # This creates the user in the Darwin system if it doesn't already exist.
  
  users.users.stefano = {
    # User's login name
    name = "stefano";
    
    # User's home directory path
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
    useGlobalPkgs = true;
    
    # Install user packages to the user's profile
    useUserPackages = true;
    
    # User-specific Home Manager configuration
    # Now pointing to the new location in users/stefano/
    users.stefano = import ./users/stefano;  # Will load users/stefano/default.nix
    
    # Enable verbose output during activation
    verbose = true;
    
    # Extra arguments passed to all Home Manager modules
    extraSpecialArgs = { };
  };
}

# =============================================================================
# References
# =============================================================================
# 
# - Home Manager manual: https://nix-community.github.io/home-manager/
# - nix-darwin manual: https://daiderd.com/nix-darwin/manual/
#
# =============================================================================
