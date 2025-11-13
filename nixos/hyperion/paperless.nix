{
  config,
  ...
}: {
  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."hyperion/paperless/passwordFile".path;
    environmentFile = config.sops.secrets."hyperion/paperless/environmentFile".path;
    mediaDir = "/data/disk2/paperless";
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "fra+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_ALLOWED_HOST = config.scarisey.homelab.settings.domains.lan.paperless.domain;
      PAPERLESS_TIMEZONE = "Europe/Paris";
    };
  };
}
