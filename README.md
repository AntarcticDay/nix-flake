
# Determinate Nix Flake

A modular, multi-system Nix flake configuration for managing macOS and NixOS systems declaratively.

Built with [Determinate Nix](https://determinate.systems/) for enhanced reliability and developer experience.

[![FlakeHub](https://img.shields.io/badge/FlakeHub-published-blue)](https://flakehub.com/flake/GglassGghosst/determinate-nix-flake/)

[![Rolling Release](https://img.shields.io/badge/release-rolling-green)](https://github.com/GglassGghosst/determinate-nix-flake)

## 📋 Overview

This flake provides a complete, reproducible system configuration using:

- **[nix-darwin](https://github.com/LnL7/nix-darwin)** - macOS system configuration
- **[Home Manager](https://github.com/nix-community/home-manager)** - User environment management
- **[nix-homebrew](https://github.com/zhaofengli/nix-homebrew)** - Declarative Homebrew management
- **Multi-channel support** - Mix stable and unstable packages safely
- **Modular structure** - Easily extensible for multiple machines

## 🏗️ Project Structure

```
.  
├── flake.nix                      # Main flake configuration  
├── flake.lock                     # Pinned dependencies  
│  
├── lib/                           # Utility functions  
│   ├── default.nix                  # Library exports  
│   ├── mkPkgs.nix                   # Package set builder with overlays  
│   └── systems.nix                  # Multi-system support utilities  
│  
├── modules/                       # Reusable configuration modules  
│   ├── common/                      # Cross-platform modules  
│   │   └── nix.nix                    # Shared Nix settings  
│   ├── darwin/                      # macOS-specific modules  
│   │   ├── default.nix                # Darwin module aggregator  
│   │   ├── system.nix                 # System settings, fonts, shells  
│   │   └── homebrew.nix               # Base Homebrew configuration  
│   └── home-manager/                # Home Manager modules  
│       └── default.nix                # Home Manager base settings  
│  
├── hosts/                         # Host-specific configurations  
│   └── macbook-pro-2018/            # MacBook Pro 2018 (Intel)  
│       ├── default.nix                # Host configuration entry  
│       ├── packages.nix               # System packages  
│       ├── home-manager.nix           # User management  
│       ├── homebrew.nix               # Host Homebrew packages  
│       ├── services/                  # System services  
│       │   └── forgejo.nix              # Forgejo Git service  
│       └── users/                     # User configurations  
│           └── stefano/  
│               ├── default.nix        # User config  
│               ├── packages.nix       # User packages  
│               └── homebrew/          # User Homebrew  
│                   ├── brew.nix         # CLI tools  
│                   ├── cask.nix         # GUI apps  
│                   └── mas.nix          # App Store apps  
│  
├── pkgs/                          # Custom packages  
│   ├── default.nix                # Package exports  
│   └── collections.nix            # Package collections  
│  
└── overlays/                      # Nixpkgs modifications  
    ├── default.nix                  # Overlay aggregator  
    ├── channels.nix                 # Stable/unstable exposure  
    └── sillytavern.nix              # Custom overlays
```

## 💻 Supported Systems

System Architecture Status:

- macOS x86_64-darwin ✅ Active

- macOS aarch64-darwin 🔄 Planned

- Linux x86_64-linux 🔄 Planned

- Linux aarch64-linux 🔄 Planned

- NixOS All architectures 🔄 Planned

## 📦 FlakeHub

This flake is published on FlakeHub with rolling releases on every push to main.

## 🛠️ Common Commands

### System Management

#### Build without switching

```
darwin-rebuild build --flake .#macbook-pro-2018

```

#### Switch to new configuration

```
darwin-rebuild switch --flake .#macbook-pro-2018
```

#### Test configuration (activate but don't make default)


```
darwin-rebuild test --flake .#macbook-pro-2018
```

#### Check flake configuration

```
nix flake check
```

#### Show flake outputs

```
nix flake show
```

### Package Management

#### Search for packages

```
nix search nixpkgs firefox
```

#### Install user packages

```
nix profile install .#
```

#### Enter development shell

```
nix develop
```

#### Run a package without installing

```
nix run nixpkgs#cowsay -- "Hello from Nix!"
```

### Updates and Maintenance

#### Update all flake inputs

```
nix flake update
```

#### Update specific input

```
nix flake lock --update-input nixpkgs
```

#### Garbage collection

```
nix-collect-garbage -d
```

#### Optimize nix store

```
nix store optimise
```

### Home Manager

#### List generations

```
home-manager generations
```

#### Rollback to previous generation

```
home-manager rollback
```

#### Show managed files

```
home-manager files
```

## 📚 Documentation

Nix Manual: https://nixos.org/manual/nix/stable/

nix-darwin Manual: https://daiderd.com/nix-darwin/manual/

Home Manager Manual: https://nix-community.github.io/home-manager/

Nixpkgs Manual: https://nixos.org/manual/nixpkgs/stable/

Determinate Systems: https://determinate.systems/
