{config, ...}: let
  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts;
in {
  services.grafana = {
    enable = true;
    settings = {
      log.level = "info";
      server = {
        root_url = "https://${config.services.scarisey.server.domains.grafana}";
        http_addr = "127.0.0.1";
        http_port = 3000;
        enable_gzip = true;
      };
      smtp.enabled = false;
      users = {
        allow_sign_up = false;
      };
    };

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

  services.nginx.virtualHosts.${config.services.scarisey.server.domains.grafana} =
    declareVirtualHostDefaults {domain = config.services.scarisey.server.domains.grafana;}
    // {
      locations."/".proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
    };
  security.acme.certs.${config.services.scarisey.server.domains.grafana} = declareCerts config.services.scarisey.server.domains.grafana;
}
