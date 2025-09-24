{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.restic;
in {
  options.scarisey.restic = {
    enable = mkEnableOption "Restic settings.";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      restic
    ];

    sops.secrets."restic/protonDrive" = {};
  };
}
