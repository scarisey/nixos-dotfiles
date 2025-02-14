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
  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = with pkgs; [
          opera
          firefox

          vlc
          mpv
          amberol

          ghostty
          neovide

          xclip
          pavucontrol
          flameshot

          scrcpy

          (mkIf cfg.obs obs-studio)
        ];

        home.file.".config/ghostty/config" = {
          source = ./ghostty/config;
        };
      }
    ]
  );
}
