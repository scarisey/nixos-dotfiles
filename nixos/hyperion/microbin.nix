{config, ...}: {
  services.microbin = {
    enable = true;
    settings = {
      MICROBIN_PUBLIC_PATH = "https://${config.services.scarisey.server.domains.exposed.microbin}/";
      MICROBIN_QR = true;
      MICROBIN_ENCRYPTION_CLIENT_SIDE = true;
      MICROBIN_DISABLE_UPDATE_CHECKING = true;
      MICROBIN_LIST_SERVER = false;
      MICROBIN_HASH_IDS = true;
      MICROBIN_ENABLE_BURN_AFTER = true;
      MICROBIN_READONLY = true;
      MICROBIN_PRIVATE = true;
      MICROBIN_NO_LISTING = true;
      MICROBIN_WIDE = true;
    };
    passwordFile = "/run/secrets/hyperion/microbin/passwordFile";
  };

  services.nginx.virtualHosts.${config.services.scarisey.server.domains.exposed.microbin}.locations."/".proxyPass = "http://127.0.0.1:8080$request_uri";

  users.groups.microbin.name = "microbin-sec";
  systemd.services.microbin.serviceConfig.SupplementaryGroups = ["microbin-sec"];
  sops.secrets."hyperion/microbin/passwordFile" = {
    mode = "0440";
    group = "microbin-sec";
  };
}
