
# overlays/sillytavern.nix
# Wrapper overlay for SillyTavern to use XDG directories

final: prev: {
  sillytavern = final.symlinkJoin {
    name = "sillytavern";
    paths = [ prev.sillytavern ];
    buildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/sillytavern \
        --run 'export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"' \
        --run 'export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"' \
        --run 'mkdir -p "$XDG_CONFIG_HOME/sillytavern" "$XDG_DATA_HOME/sillytavern"' \
        --add-flags "--configPath \$XDG_CONFIG_HOME/sillytavern/config.yaml" \
        --add-flags "--dataRoot \$XDG_DATA_HOME/sillytavern"
    '';
  };
}
