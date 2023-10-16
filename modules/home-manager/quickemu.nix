{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.quickemu;
in
{
  options.scarisey.quickemu = {
    enable = mkEnableOption "Quickemu settings";
  };
  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      quickemu
      quickgui
    ];

    home.file."quickemu/ubuntu-22.04.conf" = {
      source = ./quickemu/ubuntu-22.04.conf;
    };

  };
}
