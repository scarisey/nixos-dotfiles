{config,...}:let
 mediaDir = "/data/disk1/Photos";
in {
    systemd.tmpfiles.rules = [ "d ${mediaDir} 0775 immich ${config.scarisey.homelab.group} - -" ];
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    services.immich = {
      enable = true;
      group = config.scarisey.homelab.group;
      port = 2283;
      mediaLocation = "${mediaDir}";
    };
}
