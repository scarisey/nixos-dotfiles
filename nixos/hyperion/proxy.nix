{config, ...}: let
  rootDomain = "carisey.dev";
  plexDomain = "plex-hyperion.${rootDomain}";
  email = "sylvain@carisey.dev";
in {
  services.nginx = {
    enable = true;

    appendHttpConfig = ''
      limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;
      limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=10r/s;
    '';

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts.${rootDomain} = {
      listen = [
        {
          addr = "192.168.1.79";
          port = 8443;
          ssl = true;
        }
      ];
      http2 = true;
      useACMEHost = rootDomain;
      forceSSL = true;
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

    virtualHosts.${plexDomain} = {
      listen = [
        {
          addr = "192.168.1.79";
          port = 8080;
        }
        {
          addr = "192.168.1.79";
          port = 8443;
          ssl = true;
        }
      ];
      http2 = true;
      useACMEHost = plexDomain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:32400/";
        proxyWebsockets = true;
        extraConfig = ''
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

  security.acme.certs.${rootDomain} = {
    domain = rootDomain;
    dnsProvider = "ionos";
    dnsPropagationCheck = true;
    #check https://go-acme.github.io/lego/dns/
    environmentFile = "/var/ionos/token";
    group = "nginx";
  };
  security.acme.certs.${plexDomain} = {
    domain = plexDomain;
    dnsProvider = "ionos";
    dnsPropagationCheck = true;
    #check https://go-acme.github.io/lego/dns/
    environmentFile = "/var/ionos/token";
    group = "nginx";
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8080 8443];
  };
}
