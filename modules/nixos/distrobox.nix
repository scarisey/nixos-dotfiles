{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.scarisey.distrobox;
in {
  options.scarisey.distrobox = {
    enable = mkEnableOption "Enable distrobox";
  };
  config = mkIf cfg.enable {
    scarisey.docker.enable = true;

    environment.systemPackages = with pkgs; [
      distrobox
      xorg.xhost
    ];
  };
}
