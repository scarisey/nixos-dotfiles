{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.kde;
in
{
  options.scarisey.kde = {
    enable = mkEnableOption "My kde config";
  };
  config = mkIf cfg.enable {
    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      layout = "fr";
      xkbVariant = "azerty";
      displayManager = {
        sddm.enable = true;

      };
      desktopManager = {
        xterm.enable = false;
        plasma5.enable = true;
      };

    };
    programs.dconf.enable = true; #gnome compat
    environment.systemPackages = with pkgs;[
      krita
      kolourpaint
      plasma5Packages.kalk
      libsForQt5.qtstyleplugin-kvantum
      yakuake
      gnome.adwaita-icon-theme
    ];
  };
}
