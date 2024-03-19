{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.gui;
in {
  options.scarisey.gui = {
    enable = mkEnableOption "Common GUI tools";
    obs = mkEnableOption "OBS Studio";
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      TERMINAL = "alacritty";
    };

    home.packages = with pkgs; let
      scrcpyDesktopItem = pkgs.makeDesktopItem {
        name = "scrcpy";
        desktopName = "Screen copy";
        exec = "${unstable.scrcpy}/bin/scrcpy --video-codec=h265 --max-fps=60 --no-audio --keyboard=uhid";
        terminal = true;
      };
    in [
      unstable.google-chrome

      unstable.vlc

      alacritty
      neovide

      xclip
      pavucontrol
      flameshot

      unstable.scrcpy

      unstable.authy

      (mkIf cfg.obs unstable.obs-studio)
    ];

    home.file.".alacritty.yml" = {
      source = ./alacritty/alacritty.yml;
    };
  };
}
