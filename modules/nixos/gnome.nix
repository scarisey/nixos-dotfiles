{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.gnome;
in {
  options.scarisey.gnome = {
    enable = mkEnableOption "My gnome config";
    wayland = mkOption {
      default = true;
      example = true;
      type = lib.types.bool;
      description = "Is wayland enabled";
    };
  };
  config =
    mkIf cfg.enable
    {
      services.xserver = {
        # Enable the X11 windowing system.
        enable = true;
        # Configure keymap in X11
        xkb.layout = "fr";
        xkb.variant = "azerty";
        displayManager = {
          gdm.enable = true;
          gdm.wayland = cfg.wayland;
        };
        desktopManager = {
          gnome.enable = true;
        };
      };
      programs.dconf.enable = true;
      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        gedit
        cheese # webcam tool
        gnome-music
        epiphany # web browser
        geary # email reader
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
      ];
      environment.systemPackages = with pkgs; [
        gnome-tweaks
        gnome-extension-manager
        gnome-sound-recorder
      ];
    };
}
