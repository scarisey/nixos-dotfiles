{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.kde;
in {
  options.scarisey.kde = {
    enable = mkEnableOption "My kde config";
  };
  config = mkIf cfg.enable {
    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      xkb.layout = "fr";
      xkb.variant = "azerty";
    };
    services = {
      displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
      };
      desktopManager.plasma6.enable = true;
    };
    programs.dconf.enable = true; #gnome compat
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
    ];
  };
}
