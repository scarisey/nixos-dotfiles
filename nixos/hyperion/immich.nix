{
  config,
  pkgs,
  lib,
  ...
}: let
  mediaDir = "/data/disk1/Photos";
in {
  systemd.tmpfiles.rules = ["d ${mediaDir} 0775 immich ${config.scarisey.homelab.group} - -"];
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
  services.immich = {
    enable = true;
    package = pkgs.immich-unstable;
    group = config.scarisey.homelab.group;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "${mediaDir}";
    database = {
      enable = true;
      createDB = true;
      enableVectors = false;
      enableVectorChord = true;
    };
  };
}
