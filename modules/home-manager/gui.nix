{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.scarisey.gui;
in {
  options.scarisey.gui = {
    enable = mkEnableOption "Common GUI tools";
    obs = mkEnableOption "OBS Studio";
    nixgl = {
      enable = mkEnableOption "Enable NixGL wrappers";
      defaultWrapper = mkOption {
        type = lib.types.enum (builtins.attrNames config.lib.nixGL.wrappers);
        default = "mesa";
      };
    };
  };
  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = with pkgs;
          map (x: config.lib.nixGL.wrap x) [
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
          ];

        home.file.".config/ghostty/config" = {
          source = ./ghostty/config;
        };

        home.shellAliases = {
          nvd = "f(){neovide --frame none \${1:-$(pwd)} &> /dev/null &};f";
        };
      }
      (mkIf cfg.nixgl.enable {
        nixGL.packages = inputs.nixgl.packages;
        nixGL.defaultWrapper = cfg.nixgl.defaultWrapper;
        nixGL.installScripts = [cfg.nixgl.defaultWrapper];
      })
      (mkIf cfg.obs {
        home.packages = [(config.lib.nixGL.wrap pkgs.obs-studio)];
      })
    ]
  );
}
