{config,...}:let
 mediaDir = "/data/disk1/Photos";
in {
    systemd.tmpfiles.rules = [ "d ${mediaDir} 0775 immich ${config.scarisey.homelab.group} - -" ];
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    services.immich = {
      group = config.scarisey.homelab.group;
      enable = true;
      port = 2283;
      mediaLocation = "${mediaDir}";
    };
}
