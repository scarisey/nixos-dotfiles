{config, ...}: let
  libProxy = import ../libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts domains;
in {
  services.grafana = {
    enable = true;
    settings = {
      log.level = "info";
      server = {
        root_url = "https://${domains.grafana}";
        http_addr = "127.0.0.1";
        http_port = 3000;
        enable_gzip = true;
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{/run/secrets/hyperion/grafana/init_passwd}"; #only for first setup
        secret_key = "$__file{/run/secrets/hyperion/grafana/init_secret}"; #only for first setup
        allow_embedding = false;
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

  services.nginx.virtualHosts.${domains.grafana} =
    declareVirtualHostDefaults {domain = domains.grafana;}
    // {
      locations."/".proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
    };
  security.acme.certs.${domains.grafana} = declareCerts domains.grafana;
}
