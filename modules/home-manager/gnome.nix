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
    enable = mkEnableOption "Gnome settings";
  };
  config = mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
      };
    };
  };
}
