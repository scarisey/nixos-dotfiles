{config, ...}: {
  services.jellyfin = {
    enable = true;
  };

  services.nginx.virtualHosts.${config.services.scarisey.server.domains.exposed.jellyfin}.locations."/".proxyPass = "http://localhost:8096";
}
