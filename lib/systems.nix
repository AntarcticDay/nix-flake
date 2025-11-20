
# lib/systems.nix
# =============================================================================
# System Architecture Support Utilities
# 
# This module provides utilities for handling multiple system architectures.
# Intel Macs, Apple Silicon Macs, Linux machines, etc.
#
# Terminology:
# - System: A string like "x86_64-linux" combining CPU architecture and OS
# - Architecture: The CPU type (x86_64, aarch64, etc.)
# - Platform: The OS (linux, darwin for macOS)
# =============================================================================

let

  # ===========================================================================
  # Supported Systems Definition
  # ===========================================================================
  # 
  # This list defines all system architectures we want to support.
  # Each string follows the format: "<architecture>-<platform>"
  
  supportedSystems = [

    # ---------------------------------------------------------------------------
    # Linux Systems
    # ---------------------------------------------------------------------------
    
    # Intel/AMD 64-bit Linux
    "x86_64-linux"
    
    # ARM 64-bit Linux  
    "aarch64-linux"
    
    # ---------------------------------------------------------------------------
    # macOS (Darwin) Systems
    # ---------------------------------------------------------------------------
    
    # Intel 64-bit macOS
    "x86_64-darwin"
    
    # Apple Silicon macOS
    "aarch64-darwin"
    
    # ---------------------------------------------------------------------------
    # Potential Future Additions (commented out)
    # ---------------------------------------------------------------------------
    
    # # 32-bit systems (rarely used today)
    # "i686-linux"        # Old 32-bit Linux PCs
    # 
    # # Other Unix-like systems
    # "x86_64-freebsd"    # FreeBSD on Intel/AMD
    # "aarch64-netbsd"    # NetBSD on ARM
    # 
    # # Mobile/embedded (experimental Nix support)
    # "aarch64-android"   # Android devices
    # "aarch64-ios"       # iOS devices (very experimental)
    # 
    # # Windows via WSL2
    # "x86_64-windows"    # Requires WSL2 or similar

  ];

  # ===========================================================================
  # System Information Helpers
  # ===========================================================================
  # 
  # These helpers extract information about systems and provide useful
  # categorizations for conditional logic.
  
  # Extract the architecture (CPU type) from a system string
  # Example: "x86_64-linux" -> "x86_64"
  getArch = system: builtins.head (builtins.split "-" system);
  
  # Extract the platform (OS) from a system string
  # Example: "x86_64-linux" -> "linux"
  getPlatform = system: builtins.elemAt (builtins.split "-" system) 1;
  
  # Check if a system is Linux-based
  # Useful for Linux-specific configurations
  isLinux = system: getPlatform system == "linux";
  
  # Check if a system is macOS (Darwin)
  # Useful for macOS-specific configurations
  isDarwin = system: getPlatform system == "darwin";
  
  # Check if a system is 64-bit x86 (Intel/AMD)
  # Useful for architecture-specific optimizations
  isX86_64 = system: getArch system == "x86_64";
  
  # Check if a system is 64-bit ARM
  # Useful for ARM-specific configurations
  isAarch64 = system: getArch system == "aarch64";

in

{
  # ===========================================================================
  # Exported Functions and Values
  # ===========================================================================
  # 
  # These are the public interface of this module, available to other parts
  # of the flake.
  
  # ---------------------------------------------------------------------------
  # List of Supported Systems
  # ---------------------------------------------------------------------------
  # 
  # Export the list for other modules to use
  # Example usage: lib.supportedSystems

  inherit supportedSystems;
  
  # ---------------------------------------------------------------------------
  # System Information Helpers
  # ---------------------------------------------------------------------------
  # 
  # Export helper functions for system detection

  inherit getArch getPlatform isLinux isDarwin isX86_64 isAarch64;
  
  # ---------------------------------------------------------------------------
  # Universal System Iterator
  # ---------------------------------------------------------------------------
  # 
  # This is the main utility function for multi-platform support.
  # It applies a function to each supported system and returns
  # an attribute set with results.
 
  forAllSystems = f: 
    # builtins.listToAttrs converts a list of {name, value} pairs to an attrset
    builtins.listToAttrs (
      # map applies the function to each system in our list
      map (system: {
        name = system;           # The system string becomes the attribute name
        value = f system;        # The function result becomes the value
      }) supportedSystems
    );
  
  # ---------------------------------------------------------------------------
  # Conditional System Iterator
  # ---------------------------------------------------------------------------
  # 
  # Like forAllSystems, but with filtering capability
  # Useful when certain things only apply to some systems
  
  forMatchingSystems = predicate: f:
    builtins.listToAttrs (
      map (system: {
        name = system;
        value = f system;
      }) (builtins.filter predicate supportedSystems)
    );

  # ---------------------------------------------------------------------------
  # System Grouping Utilities
  # ---------------------------------------------------------------------------
  # 
  # Pre-filtered lists for common use cases
  
  # All Linux systems we support
  linuxSystems = builtins.filter isLinux supportedSystems;
  # Result: [ "x86_64-linux" "aarch64-linux" ]
  
  # All macOS systems we support
  darwinSystems = builtins.filter isDarwin supportedSystems;
  # Result: [ "x86_64-darwin" "aarch64-darwin" ]
  
  # All x86_64 systems (Intel/AMD)
  x86_64Systems = builtins.filter isX86_64 supportedSystems;
  # Result: [ "x86_64-linux" "x86_64-darwin" ]
  
  # All ARM64 systems
  aarch64Systems = builtins.filter isAarch64 supportedSystems;
  # Result: [ "aarch64-linux" "aarch64-darwin" ]

}

# =============================================================================
# Usage Examples
# =============================================================================
# 
# In flake.nix:
# ```nix
# {
#   # Build packages for all systems
#   packages = lib.forAllSystems (system:
#     let pkgs = nixpkgs.legacyPackages.${system};
#     in {
#       myapp = pkgs.callPackage ./myapp.nix { };
#     }
#   );
#   
#   # Or build only for Darwin systems
#   darwinPackages = lib.forMatchingSystems lib.isDarwin (system: {
#     # macOS-specific packages
#   });
# }
# ```
# 
# In a configuration module:
# ```nix
# { system, lib, ... }:
# {
#   # Conditional configuration based on system
#   services.xserver.enable = lib.isLinux system;
#   
#   # Architecture-specific optimizations
#   boot.kernelParams = lib.optionals (lib.isX86_64 system) [
#     "intel_pstate=active"
#   ];
# }
# ```
#
# =============================================================================
# Adding Support for New Systems
# =============================================================================
# 
# To add a new system:
# 
# 1. Add it to the `supportedSystems` list
# 2. Test that packages build: `nix build .#packages.newsystem.default`
# 3. Add any system-specific configuration in host modules
# 
# Considerations:
# - Ensure nixpkgs supports the system
# - Some packages may not be available
# - May need system-specific overlays
#
# =============================================================================
# Common Issues and Solutions
# =============================================================================
# 
# **"unsupported system" errors**:
# - Package doesn't support that architecture
# - Add conditional logic or find alternative
# 
# **Performance on multiple systems**:
# - Building for all systems takes time
# - Use Nix's binary cache when possible
# - Consider CI/CD for multi-system builds
# 
# **Cross-compilation**:
# - Building for a different system than you're on
# - More complex, may need special configuration
# - See nixpkgs manual on cross-compilation
#
# =============================================================================
# Notes 
# =============================================================================
# 
# Docs (official):
# - Systems & platforms: https://nixos.org/manual/nixpkgs/stable/#systems
# =============================================================================
