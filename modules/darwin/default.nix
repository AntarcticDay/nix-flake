
# modules/darwin/default.nix
# =============================================================================
# Darwin Modules Entry Point
# 
# This is the main entry point for all Darwin (macOS) system configuration
# modules. It imports and combines all the Darwin-specific modules to create
# a complete system configuration.
#
# Purpose:
# - Central import point for Darwin modules
# - Configures base Nix settings for Determinate Nix compatibility
# - Ensures all Darwin modules are loaded in the correct order
#
# Module structure:
# - This file: Imports all Darwin modules and sets base configuration
# - system.nix: Shell, fonts, and system-level settings
# - homebrew.nix: Homebrew package manager integration
#
# When a host imports this directory, all these modules are automatically
# included, providing a complete Darwin system configuration.
# =============================================================================

{ pkgs, lib, config, ... }:

{

  # ===========================================================================
  # Module Imports
  # ===========================================================================
  # 
  # Import all Darwin-specific configuration modules.
  # Order matters: more general modules should come before specific ones.
  
  imports = [

    # Common cross-platform Nix settings
    ../common/nix.nix
    
    # System-level configuration (shells, fonts, system preferences)
    ./system.nix
    
    # Homebrew integration for installing macOS applications
    ./homebrew.nix
  ];
    
    # Future modules could include:
    # ./security.nix     # FileVault, firewall, privacy settings
    # ./networking.nix   # Network configuration, VPN settings
    # ./services.nix     # LaunchAgents and LaunchDaemons
  ];

  # ===========================================================================
  # Base Nix Configuration
  # ===========================================================================
  # 
  # IMPORTANT: We're using Determinate Nix, which manages its own Nix daemon
  # and configuration. This section ensures compatibility.
  
  nix = {
    # ---------------------------------------------------------------------------
    # Nix Daemon Management
    # ---------------------------------------------------------------------------
    # 
    # CRITICAL: This must be false when using Determinate Nix!
    # 
    # Why enable = false?
    # - Determinate Nix installs and manages its own Nix daemon
    # - It provides optimized configuration in /etc/nix/nix.conf
    # - It runs additional services (like Determinate Nixd for FlakeHub)
    # - Setting this to true would conflict with Determinate's setup
    # 
    # What Determinate Nix provides:
    # - Standard Nix daemon (same as upstream Nix)
    # - Automatic flakes and nix-command enablement
    # - FlakeHub authentication and caching
    # - Optimized store settings
    # - Automatic garbage collection
    # 
    # Reference: https://docs.determinate.systems/determinate-nix/
    enable = false;
    
    # ---------------------------------------------------------------------------
    # Experimental Features
    # ---------------------------------------------------------------------------
    # 
    # These features are already enabled by Determinate Nix, but we declare
    # them here for documentation and clarity.
    # 
    # What these features provide:
    # - "nix-command": New `nix` CLI with better UX (nix build, nix develop, etc.)
    # - "flakes": Reproducible, declarative Nix projects with flake.nix
    # 
    # Even though Determinate Nix enables these, declaring them here:
    # 1. Documents what features we rely on
    # 2. Ensures compatibility if someone switches away from Determinate Nix
    # 3. Makes our requirements explicit
    settings.experimental-features = [ "nix-command" "flakes" ];
    
    # ---------------------------------------------------------------------------
    # Additional Nix Settings (Optional)
    # ---------------------------------------------------------------------------
    # 
    # These settings would normally go here, but with Determinate Nix,
    # they should be managed through Determinate's configuration.
    # Shown here for reference only - uncomment with caution!
    
    # # Trusted users who can use advanced Nix features
    # settings.trusted-users = [ "@admin" "stefano" ];
    # 
    # # Binary caches for faster package downloads
    # settings.substituters = [
    #   "https://cache.nixos.org"
    #   "https://nix-community.cachix.org"
    # ];
    # 
    # # Public keys for binary caches
    # settings.trusted-public-keys = [
    #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # ];
    # 
    # # Build settings
    # settings.max-jobs = "auto";  # Build jobs in parallel
    # settings.cores = 0;          # Use all CPU cores
    # 
    # # Store optimization
    # settings.auto-optimise-store = true;  # Deduplicate store files
  };

  # ===========================================================================
  # Darwin-Specific Base Settings
  # ===========================================================================
  # 
  # These settings are Darwin-specific and safe to set even with Determinate Nix
  
  # Enable Touch ID for sudo (if available on the hardware)
  # This is set per-host but shown here as an example
  # security.pam.enableSudoTouchIdAuth = true;
  
  # System-wide environment variables
  # These are available to all users and processes
  environment.variables = {
    # Ensure Nix tools are in the PATH
    # Determinate Nix handles this, but being explicit doesn't hurt
    NIX_PATH = lib.mkDefault "nixpkgs=flake:nixpkgs";
    
    # You can add other global variables here
    # ORGANIZATION = "My Company";
    # DEFAULT_BROWSER = "firefox";
  };

  # ===========================================================================
  # System Integration
  # ===========================================================================
  # 
  # Ensure Darwin system integrates well with Nix
  
  # Programs that need special Darwin integration
  programs = {
    # Enable Nix integration for shells
    # This ensures nix commands work in all shells
    bash.enable = true;  # Even if using zsh, bash should be available
    
    # Additional programs are configured in system.nix
  };

}

# =============================================================================
# Understanding Determinate Nix vs Standard Nix
# =============================================================================
# 
# **Standard Nix-Darwin Approach**:
# - nix-darwin manages the Nix daemon
# - Configuration through nix.* options
# - Manual setup of experimental features
# - User manages binary caches
# 
# **Determinate Nix Approach**:
# - Determinate installer manages the daemon
# - Configuration through /etc/nix/nix.conf
# - Automatic feature enablement
# - Integrated FlakeHub caching
# - Additional Determinate Nixd service
# 
# **Why This Matters**:
# - Avoid conflicts by not managing what Determinate manages
# - Let each tool do what it does best
# - Determinate for Nix infrastructure, nix-darwin for system config
#
# =============================================================================
# Adding New Modules
# =============================================================================
# 
# To add a new Darwin module:
# 
# 1. Create a new file (e.g., `security.nix`)
# 2. Add it to the imports list above
# 3. Structure it like the existing modules:
#    ```nix
#    { pkgs, lib, config, ... }:
#    {
#      # Your configuration here
#    }
#    ```
# 
# Common module patterns:
# - System services: services.* options
# - Security settings: security.* options  
# - Network config: networking.* options
# - User management: users.* options
#
# =============================================================================
# Troubleshooting
# =============================================================================
# 
# **"Permission denied" errors**:
# - Ensure you're in the admin group
# - Check Determinate Nix is properly installed
# - Run with sudo if needed: `sudo darwin-rebuild switch`
# 
# **"Conflicting definitions" errors**:
# - Two modules defining the same option
# - Use mkForce to override: `lib.mkForce value`
# - Or use mkDefault for lower priority
# 
# **Changes not taking effect**:
# - Some changes need logout/restart
# - Check the option is actually used by Darwin
# - Verify no typos in option names
#
# =============================================================================
# References
# =============================================================================
# 
# - Determinate Nix: https://docs.determinate.systems/determinate-nix/
# - nix-darwin manual: https://daiderd.com/nix-darwin/manual/
# - Nix pills (module system): https://nixos.org/guides/nix-pills/
# 
# =============================================================================
