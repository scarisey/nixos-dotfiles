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
  };
  config =
    mkIf cfg.enable
    {
      services.xserver.xkb.layout = config.console.keyMap;
      services.displayManager = {
        gdm.enable = true;
      };
      services.desktopManager = {
        gnome.enable = true;
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
