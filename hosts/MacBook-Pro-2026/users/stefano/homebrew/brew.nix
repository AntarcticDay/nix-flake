# hosts/macbook-pro-2018/users/stefano/homebrew/brew.nix
# =============================================================================
# User-specific CLI tools via Homebrew
# 
# This file contains CLI tools that are specific to this user's workflow.
# System-wide CLI tools should go in the host's homebrew.nix instead.
# =============================================================================

[
  # User-specific CLI tools can be added here
  # For now, keeping empty as most CLI tools are system-wide

  "zsh"               # UNIX shell (command interpreter)
  "mas"               # Mac App Store command-line interface
  "gh"                # GitHub CLI (if only this user uses GitHub)
  "vim"               # Vi 'workalike' with many additional features
  "neovim"            # Ambitious Vim-fork focused on extensibility and agility
  # "emacs"           # GNU Emacs text editor
  "git"               # Distributed revision control system
  "htop"              # Improved top (interactive process viewer)
  "fastfetch"         # Like neofetch, but much faster because written mostly in C
  "speedtest-cli"     # Command-line interface for https://speedtest.net bandwidth tests
  "yt-dlp"            # Feature-rich command-line audio/video downloader
  "wget"              # Internet file retriever
  "fd"                # Simple, fast and user-friendly alternative to find
  "fontconfig"        # XML-based font configuration API for X Windows
  "grep"              # GNU grep, egrep and fgrep
  "ripgrep"           # Search tool like grep and The Silver Searcher
  "coreutils"         # GNU File, Shell, and Text utilities
  "shellcheck"        # Static analysis and lint tool, for (ba)sh scripts
  # "pandoc"          # Swiss-army knife of markup format conversion
  "jq"                # Lightweight and flexible command-line JSON processor
  "asciidoctor"       # Text processor and publishing toolchain for AsciiDoc

  "python@3.12"       # Interpreted, interactive, object-oriented programming language

  # "pkgconf"         # Package compiler and linker metadata toolkit
  # "automake"        # Tool for generating GNU Standards-compliant Makefiles
  # "texinfo"         # Official documentation format of the GNU project
  # "libgccjit"       # JIT library for the GNU compiler collection
  # "gnutls"          # GNU Transport Layer Security (TLS) Library
  # "jansson"         # C library for encoding, decoding, and manipulating JSON
  # "libxml2"         # GNOME XML library
  # "libpng"          # Library for manipulating PNG images
  # "librsvg"         # Library to render SVG files using Cairo
  # "jpeg"            # Image manipulation library
  # "giflib"          # Library and utilities for processing GIFs
  # "libtiff"         # TIFF library and utilities

]
