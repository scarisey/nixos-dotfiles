{config, ...}: let
  rootDomain = "carisey.dev";
  plexDomain = "plex-hyperion.${rootDomain}";
  nixcacheDomain = "nixcache-hyperion.${rootDomain}";
  grafanaDomain = "grafana-hyperion.${rootDomain}";
  email = "sylvain@carisey.dev";

  declareCerts = domain: {
    inherit domain;
    #check https://go-acme.github.io/lego/dns/
    dnsProvider = "ionos";
    dnsPropagationCheck = true;
    environmentFile = "/var/ionos/token";
    group = "nginx";
  };

  declareVirtualHostDefaults = domain: {
    listen = [
      {
        addr = "192.168.1.79";
        port = 8443; #NAT 443 to 8443
        ssl = true;
      }
    ];
    http2 = true;
    useACMEHost = domain;
    forceSSL = true;
  };
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

    virtualHosts.${rootDomain} =
      declareVirtualHostDefaults rootDomain
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

    virtualHosts.${plexDomain} =
      declareVirtualHostDefaults plexDomain
      // {
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
    virtualHosts.${nixcacheDomain} =
      declareVirtualHostDefaults nixcacheDomain
      // {
        locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    virtualHosts.${grafanaDomain} =
      declareVirtualHostDefaults grafanaDomain
      // {
        locations."/".proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      };
  };
  users.users.nginx.extraGroups = ["acme"];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = email;

  security.acme.certs.${rootDomain} = declareCerts rootDomain;
  security.acme.certs.${plexDomain} = declareCerts plexDomain;
  security.acme.certs.${nixcacheDomain} = declareCerts nixcacheDomain;
  security.acme.certs.${grafanaDomain} = declareCerts grafanaDomain;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8080 8443];
  };
}
