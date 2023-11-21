{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.gui;
in
{
  options.scarisey.gui = {
    enable = mkEnableOption "Common GUI tools";
    obs = mkEnableOption "OBS Studio";
  };
  config = mkIf cfg.enable {

    home.sessionVariables = {
      TERMINAL = "alacritty";
    };

    home.packages = with pkgs; [
      unstable.google-chrome

      alacritty

      xclip
      pavucontrol
      flameshot

      unstable.authy

      (mkIf cfg.obs unstable.obs-studio)
    ] ;

    home.file.".alacritty.yml" = {
      source = ./alacritty/alacritty.yml;
    };
  };
}
