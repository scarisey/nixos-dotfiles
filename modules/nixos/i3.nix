#The whole i3 configuration is inspired from https://github.com/ryan4yin/nix-config

{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.i3Xfce;
in
{

  options.scarisey.i3Xfce = {
    enable = mkEnableOption "My i3 config";
  };
  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
    services = {
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumbnail support for images

      xserver = {
        # Enable the X11 windowing system.
        enable = true;
        # Configure keymap in X11
        layout = "fr";
        xkbVariant = "azerty";

        desktopManager = {
          xterm.enable = false;
          xfce = {
            enable = true;
            noDesktop = true;
            enableXfwm = false;
          };
        };
        displayManager = {
          defaultSession = "xfce+i3";
          gdm = {
            enable = true;
            wayland = false;
          };
        };
        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            rofi # application launcher, the same as dmenu
            dunst # notification daemon
            i3blocks # status bar
            i3lock # default i3 screen locker
            i3status # provide information to i3bar
            i3-gaps # i3 with gaps
            picom # transparency and shadows
            feh # set wallpaper
          ];
        };

      };
    };
  };
}
