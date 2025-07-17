{config, declareVirtualHostDefaults, declareCerts, ...}:let
  microbinDomain = config.scarisey.homelab.settings.domains.lan.microbin.domain;
in{
  services.microbin = {
    enable = true;
    settings = {
      MICROBIN_PUBLIC_PATH = "https://${microbinDomain}/";
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
  };

  users.groups.microbin.name = "microbin-sec";
  systemd.services.microbin.serviceConfig.SupplementaryGroups = ["microbin-sec"];
}
