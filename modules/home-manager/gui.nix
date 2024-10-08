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
      TERMINAL = "kitty";
    };

    programs.firefox.enable = true;

    home.packages = with pkgs; [
      vlc

      kitty
      alacritty
      neovide

      xclip
      pavucontrol
      flameshot

      scrcpy

      (mkIf cfg.obs obs-studio)
    ];

    home.file.".alacritty.toml" = {
      source = ./alacritty/alacritty.toml;
    };

    home.file.".config/kitty/kitty.conf" = {
      source = ./kitty/kitty.conf;
    };
    home.file.".config/kitty/nord-theme.conf" = {
      source = ./kitty/nord-theme.conf;
    };
  };
}
