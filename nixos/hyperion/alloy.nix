{config,pkgs, ...}: {
  services.alloy.enable = true;
  # services.alloy.extraFlags = [
  #   "--server.http.listen-addr=127.0.0.1:9200"
  #   "--stability.level"
  #   "experimental"
  # ];
  # should also enable live debugging
  environment.etc."alloy/config.alloy".text = ''
    logging {
      level = "info"
    }

    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
      }
    }

    local.file_match "nginx_logs" {
      path_targets = [
        {"__path__" = "/var/log/nginx/json_access.log","job"="nginx","hostname" = constants.hostname},
      ]
      sync_period = "5s"
    }

    loki.source.file "nginx" {
      targets    = local.file_match.nginx_logs.targets
      forward_to = [loki.write.local.receiver]
    }
  '';


   system.activationScripts.setAlloyACLs = {
    text = ''
      ${pkgs.acl}/bin/setfacl -dR -m u:alloy:rx /var/log/nginx
      ${pkgs.acl}/bin/setfacl -R -m u:alloy:rx /var/log/nginx
      ${pkgs.acl}/bin/setfacl -R -m u:alloy:r /var/log/nginx/access*.log
    '';
  };
}
