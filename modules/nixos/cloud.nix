{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.cloud;
in {
  options.scarisey.cloud = {
    enable = mkEnableOption "My cloud config";
    all = mkEnableOption "All cloud software installed";
    docker = mkEnableOption "Docker";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = cfg.all || cfg.docker;
  };
}
