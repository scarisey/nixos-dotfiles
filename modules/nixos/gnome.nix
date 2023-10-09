{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.gnome;
in
{
  options.scarisey.gnome = {
    enable = mkEnableOption "My gnome config";
  };
  config = mkIf cfg.enable {
    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      layout = "fr";
      xkbVariant = "azerty";
      displayManager = {
        gdm.enable = true;

      };
      desktopManager = {
        gnome.enable = true;
      };

    };
  };
}
