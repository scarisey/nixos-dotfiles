{
  config,
  lib,
  pkgs,
  ...
}: let
  domains = config.scarisey.homelab.settings.domains;
  customSettings = config.scarisey.homelab.settings.grafana;
  inherit (lib.libProxy) declareVirtualHostDefaults declareCerts;
in {
  services.grafana = {
    enable = true;
    settings =
      {
        log.level = "info";
        server = {
          root_url = "https://${domains.grafana}";
          http_addr = "127.0.0.1";
          http_port = 3000;
          enable_gzip = true;
        };
        security = {
          allow_embedding = false;
        };
        smtp.enabled = false;
        users = {
          allow_sign_up = false;
        };
      }
      // customSettings;

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
      };
    };
  };

  services.nginx.virtualHosts.${domains.grafana} =
    declareVirtualHostDefaults {domain = domains.grafana;}
    // {
      locations."/".proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
    };
  security.acme.certs.${domains.grafana} = declareCerts domains.grafana;
}
