{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.cosmic;
in {
  options.scarisey.cosmic = {
    enable = mkEnableOption "Enable Cosmic Desktop environment.";
  };
  config =
    mkIf cfg.enable
    {
      services.xserver.xkb.layout = config.console.keyMap;
      services.displayManager = {
        cosmic-greeter.enable = true;
      };
      services.desktopManager = {
        cosmic.enable = true;
      };
      programs.dconf.enable = true;
    };
}
