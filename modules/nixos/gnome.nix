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
  config = mkIf cfg.enable {
    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      layout = "fr";
      xkbVariant = "azerty";
      displayManager = {
        gdm.enable = true;
        gdm.wayland = false;
      };
      desktopManager = {
        gnome.enable = true;
      };
    };

    programs.dconf.enable = true;
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        gedit # text editor
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
      ]);
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];
  };
}
