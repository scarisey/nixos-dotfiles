{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.scarisey.docker;
in {
  options.scarisey.docker = {
    enable = mkEnableOption "Enable docker";
  };
  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      storageDriver = "overlay2";
      autoPrune = {
        enable = true;
        dates = "Fri *-*-* 05:00:00";
      };
    };
  };
}
