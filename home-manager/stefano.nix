
{ pkgs, lib, config, ... }:

let

  cfgHome = config.xdg.configHome;   # tipicamente "$HOME/.config"

in

  {

    home = {

      username      = "stefano";
     homeDirectory = "/Users/stefano";
      #  forse superflui, già definiti nel flake

      stateVersion  = "25.05";	# versione di Home Manager a cui ci "ancoriamo"

     };

    xdg.enable = true;

    programs.direnv = {
      enable = true;                 # attiva direnv
      nix-direnv.enable = true;      # carica il plug-in “nix-direnv”
     };

    # --- overlay to wrap SillyTavern ----------------------------------

    home.activation.copySillyTavernConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        dst="${cfgHome}/sillytavern/config.yaml"
        if [ ! -f "$dst" ]; then
          echo "🌱  Installing initial SillyTavern config → $dst"
          mkdir -p "$(dirname "$dst")"
          cp ${pkgs.sillytavern}/opt/sillytavern/default/config.yaml "$dst"
        fi
      '';

    # --- / overlay to wrap SillyTavern ----------------------------------

   }
