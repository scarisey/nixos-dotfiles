{config, ...}: let
  ipv4 = config.scarisey.network.settings.hyperion.ipv4;
  ipv6 = config.scarisey.network.settings.hyperion.ipv6;
  localSslPort = config.scarisey.network.settings.hyperion.ssl.local.port;
  remoteSslPort = config.scarisey.network.settings.hyperion.ssl.remote.port;

  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts domains;
in {
  services.nginx = {
    enable = true;
    statusPage = true;

    appendHttpConfig = ''
      limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;
      limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=10r/s;
      log_format json_analytics escape=json '{'
                            '"msec": "$msec", ' # request unixtime in seconds with a milliseconds resolution
                            '"connection": "$connection", ' # connection serial number
                            '"connection_requests": "$connection_requests", ' # number of requests made in connection
                    '"pid": "$pid", ' # process pid
                    '"request_id": "$request_id", ' # the unique request id
                    '"request_length": "$request_length", ' # request length (including headers and body)
                    '"remote_addr": "$remote_addr", ' # client IP
                    '"remote_user": "$remote_user", ' # client HTTP username
                    '"remote_port": "$remote_port", ' # client port
                    '"time_local": "$time_local", '
                    '"time_iso8601": "$time_iso8601", ' # local time in the ISO 8601 standard format
                    '"request": "$request", ' # full path no arguments if the request
                    '"request_uri": "$request_uri", ' # full path and arguments if the request
                    '"args": "$args", ' # args
                    '"status": "$status", ' # response status code
                    '"body_bytes_sent": "$body_bytes_sent", ' # the number of body bytes exclude headers sent to a client
                    '"bytes_sent": "$bytes_sent", ' # the number of bytes sent to a client
                    '"http_referer": "$http_referer", ' # HTTP referer
                    '"http_user_agent": "$http_user_agent", ' # user agent
                    '"http_x_forwarded_for": "$http_x_forwarded_for", ' # http_x_forwarded_for
                    '"http_host": "$http_host", ' # the request Host: header
                    '"server_name": "$server_name", ' # the name of the vhost serving the request
                    '"request_time": "$request_time", ' # request processing time in seconds with msec resolution
                    '"upstream": "$upstream_addr", ' # upstream backend server for proxied requests
                    '"upstream_connect_time": "$upstream_connect_time", ' # upstream handshake time incl. TLS
                    '"upstream_header_time": "$upstream_header_time", ' # time spent receiving upstream headers
                    '"upstream_response_time": "$upstream_response_time", ' # time spend receiving upstream body
                    '"upstream_response_length": "$upstream_response_length", ' # upstream response length
                    '"upstream_cache_status": "$upstream_cache_status", ' # cache HIT/MISS where applicable
                    '"ssl_protocol": "$ssl_protocol", ' # TLS protocol
                    '"ssl_cipher": "$ssl_cipher", ' # TLS cipher
                    '"scheme": "$scheme", ' # http or https
                    '"request_method": "$request_method", ' # request method
                    '"server_protocol": "$server_protocol", ' # request protocol, like HTTP/1.1 or HTTP/2.0
                    '"pipe": "$pipe", ' # "p" if request was pipelined, "." otherwise
                    '"gzip_ratio": "$gzip_ratio", '
                    '"http_cf_ray": "$http_cf_ray",'
                    '}';

      access_log /var/log/nginx/json_access.log json_analytics;
    '';

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts."localhost" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 9113;
        }
      ];
      locations."/nginx_status" = {
        extraConfig = ''
          stub_status;
          allow 127.0.0.1;
          deny all;
        '';
      };
    };

    virtualHosts.${domains.root} =
      declareVirtualHostDefaults {domain = domains.root;}
      // {
        locations."/" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
            #basic ddos protection
            limit_req zone=req_limit_per_ip;
            limit_conn conn_limit_per_ip 2;
          '';
        };
      };

    virtualHosts.${domains.internal} =
      declareVirtualHostDefaults {domain = domains.internal;}
      // {
        locations."/" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
            #basic ddos protection
            limit_req zone=req_limit_per_ip;
            limit_conn conn_limit_per_ip 2;
          '';
        };
      };
  };
  users.users.nginx.extraGroups = ["acme"];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = config.scarisey.network.settings.email;

  security.acme.certs.${domains.root} = declareCerts domains.root;
  security.acme.certs.${domains.internal} = declareCerts domains.wildcardInternal;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [localSslPort remoteSslPort];
  };
}
