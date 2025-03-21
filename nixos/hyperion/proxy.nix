{config, ...}: let
  domain = "hyperion.carisey.dev";
  email = "sylvain@carisey.dev";
in {
  services.nginx = {
    enable = true;

    # TODO wip on basic DDoS protection :
    # https://www.ouiheberg.com/en/blog/renforcer-la-securite-de-nginx-pour-prevenir-les-attaques-ddos
    # https://ddos-guard.net/blog/ddos-protection-with-nginx
    appendHttpConfig = ''
      # Define a zone to track connections from each IP
      limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;
      # Define a zone to track requests from each IP
      limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=10r/s;
    '';

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts.${domain} = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8080;
        }
        {
          addr = "127.0.0.1";
          port = 8443;
          ssl = true;
        }
        {
          addr = "[::1]";
          port = 8080;
        }
        {
          addr = "[::1]";
          port = 8443;
          ssl = true;
        }
      ];
      http2 = true;
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        return = "200 '<html><body>Hello world!</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
      locations."/plex" = {
        proxyPass = "http://127.0.0.1:32400/";
        proxyWebsockets = true;
        extraConfig = ''
          #basic ddos protection
          limit_req_zone=req_limit_per_ip;
          limit_conn conn_limit_per_ip  50;

          send_timeout 100m;
          gzip_disable "MSIE [1-6]\.";
          client_max_body_size 100M;
          proxy_buffering off;
          proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
          proxy_set_header X-Plex-Device $http_x_plex_device;
          proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
          proxy_set_header X-Plex-Platform $http_x_plex_platform;
          proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
          proxy_set_header X-Plex-Product $http_x_plex_product;
          proxy_set_header X-Plex-Token $http_x_plex_token;
          proxy_set_header X-Plex-Version $http_x_plex_version;
          proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
          proxy_set_header X-Plex-Provides $http_x_plex_provides;
          proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
          proxy_set_header X-Plex-Model $http_x_plex_model;
        '';
      };
    };
  };
  users.users.nginx.extraGroups = ["acme"];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = email;

  security.acme.certs.${domain} = {
    inherit domain;
    dnsProvider = "ionos";
    dnsPropagationCheck = true;
    #check https://go-acme.github.io/lego/dns/
    credentialsFile = "/var/ionos/token";
  };
}
