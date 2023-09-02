#The whole i3 configuration is inspired from https://github.com/ryan4yin/nix-config

{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.i3;
in
{

  options.scarisey.i3 = {
    enable = mkEnableOption "My i3 config";
  };
  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
    services = {
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumbnail support for images
      xserver = {
        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            rofi # application launcher, the same as dmenu
            dunst # notification daemon
            i3blocks # status bar
            i3lock # default i3 screen locker
            xautolock # lock screen after some time
            i3status # provide information to i3bar
            i3-gaps # i3 with gaps
            picom # transparency and shadows
            feh # set wallpaper
            xcolor # color picker

            acpi # battery information
            arandr # screen layout manager
            dex # autostart applications
            xbindkeys # bind keys to commands
            xorg.xbacklight # control screen brightness, the same as light
            xorg.xdpyinfo # get screen information
            scrot # minimal screen capture tool, used by i3 blur lock to take a screenshot
            sysstat # get system information
            alsa-utils # provides amixer/alsamixer/...
            blueberry #bluetooth
            networkmanagerapplet

            xfce.thunar # xfce4's file manager
          ];
        };

      };
    };

    # thunar file manager(part of xfce) related options
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
}
