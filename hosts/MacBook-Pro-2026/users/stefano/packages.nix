# hosts/macbook-pro-2018/users/stefano/packages.nix
# =============================================================================
# User-specific packages for stefano
# 
# These packages are installed only for this user, not system-wide.
# They will be available in the user's PATH but not for other users.
# =============================================================================

{ pkgs, ... }:

{
  # User-specific packages
  home.packages = with pkgs; [
    # Development tools specific to this user
    # httpie         # API testing tool
    # postman        # API development environment
    
    # Personal productivity tools
    # obsidian       # Note-taking app
    # notion         # All-in-one workspace
    
    # User-specific utilities
    # tree           # Directory tree viewer
    # tldr           # Simplified man pages
  ];
}
