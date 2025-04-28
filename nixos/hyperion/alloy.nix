{config, ...}: {
  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".text = ''
    logging {
      level = "info"
    }

    loki.write "local" {
      endpoint {
        url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
      }
    }

    local.file_match "nginx_logs" {
      path_targets = [
        {"__path__" = "/var/log/nginx/json_access.log"},
      ]
    }

    loki.source.file "nginx" {
      targets    = local.file_match.nginx_logs.targets
      forward_to = [loki.write.local.receiver]
    }
  '';
}
