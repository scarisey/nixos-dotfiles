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
    services.xserver.xkb.layout = config.console.keyMap;
    services = {
      displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
      };
      desktopManager.plasma6.enable = true;
    };
    programs.dconf.enable = true; #gnome compat
    environment.systemPackages = with pkgs; [
     # KDE Utilities
      kdePackages.discover # Optional: Software center for Flatpaks/firmware updates
      kdePackages.kcalc # Calculator
      kdePackages.kcharselect # Character map
      kdePackages.kclock # Clock app
      kdePackages.kcolorchooser # Color picker
      kdePackages.kolourpaint # Simple paint program
      kdePackages.ksystemlog # System log viewer
      kdePackages.sddm-kcm # SDDM configuration module
      kdiff3 # File/directory comparison tool
      
      # Hardware/System Utilities (Optional)
      kdePackages.isoimagewriter # Write hybrid ISOs to USB
      kdePackages.partitionmanager # Disk and partition management
      hardinfo2 # System benchmarks and hardware info
      wayland-utils # Wayland diagnostic tools
      wl-clipboard # Wayland copy/paste support
      vlc # Media player
    ];
  };
}
