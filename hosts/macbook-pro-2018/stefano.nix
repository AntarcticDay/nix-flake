
# hosts/macbook-pro-2018/stefano.nix
# User configuration for stefano on this host

{ pkgs, lib, config, ... }:

let
  cfgHome = config.xdg.configHome;   # typically "$HOME/.config"
in
{
  home = {
    username = "stefano";
    homeDirectory = "/Users/stefano";
    stateVersion = "25.05";
  };

  xdg.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # SillyTavern config initialization
  home.activation.copySillyTavernConfig =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dst="${cfgHome}/sillytavern/config.yaml"
      if [ ! -f "$dst" ]; then
        echo "🌱  Installing initial SillyTavern config → $dst"
        mkdir -p "$(dirname "$dst")"
        cp ${pkgs.sillytavern}/opt/sillytavern/default/config.yaml "$dst"
      fi
    '';
}
