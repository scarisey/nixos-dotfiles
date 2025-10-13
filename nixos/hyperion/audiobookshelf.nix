{config, ...}: {
  services.audiobookshelf = {
    enable = true;
    host = "127.0.0.1";
    port = 8010;
    group = config.scarisey.homelab.group;
    openFirewall = false;
  };
}
