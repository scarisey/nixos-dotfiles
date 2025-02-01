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
    stylix = mkEnableOption "Stylix";
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

      (mkIf (cfg.stylix) {
        stylix = {
          enable = true;
          polarity = "dark";
          fonts = {
            serif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Serif";
            };

            sansSerif = {
              package = pkgs.dejavu_fonts;
              name = "Ubuntu Regular";
            };

            monospace = {
              package = pkgs.dejavu_fonts;
              name = "UbuntuMono Nerd Font Regular";
            };

            emoji = {
              package = pkgs.noto-fonts-emoji;
              name = "Noto Color Emoji";
            };
          };
          base16Scheme = "${pkgs.base16-schemes}/share/themes/shadesmear-dark.yaml";
        };
      })
    ]
  );
}
