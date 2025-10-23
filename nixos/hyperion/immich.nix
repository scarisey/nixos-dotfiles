{
  config,
  pkgs,
  ...
}: let
  mediaDir = "/data/disk1/Photos";
in {
  # nixpkgs.config.allowBroken = true; #FIXME for immich to build

  systemd.tmpfiles.rules = ["d ${mediaDir} 0775 immich ${config.scarisey.homelab.group} - -"];
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
  services.immich = {
    enable = true;
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
