{config, ...}: let
  domains = config.scarisey.network.settings.hyperion.domains;
  ipv4 = config.scarisey.network.settings.hyperion.ipv4;
  ipv6 = config.scarisey.network.settings.hyperion.ipv6;

  localSslPort = 443;
  remoteSslPort = 8443;

  declareCerts = domain: {
    inherit domain;
    #check https://go-acme.github.io/lego/dns/
    dnsProvider = "ionos";
    dnsPropagationCheck = true;
    environmentFile = "/var/ionos/token";
    group = "acme";
  };

  ifLocalListen = localOnly:
    [
      {
        addr = ipv4;
        port = localSslPort;
        ssl = true;
      }
    ]
    ++ (
      if localOnly
      then []
      else [
        {
          addr = ipv4;
          port = remoteSslPort;
          ssl = true;
        }
      ]
    );

  declareVirtualHostDefaults = {
    domain,
    localOnly ? false,
  }: {
    listen = ifLocalListen localOnly;
    http2 = true;
    useACMEHost =
      if localOnly
      then domains.internal
      else domain;
    forceSSL = true;
  };
in {
  services.nginx = {
    enable = true;
    statusPage = true;

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

    virtualHosts.${domains.plex} =
      declareVirtualHostDefaults {domain = domains.plex;}
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
    virtualHosts.${domains.grafana} =
      declareVirtualHostDefaults {domain = domains.grafana;}
      // {
        locations."/".proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      };

    virtualHosts.${domains.pgadmin} =
      declareVirtualHostDefaults {
        domain = domains.pgadmin;
        localOnly = true;
      }
      // {
        locations."/".proxyPass = "http://localhost:${toString config.services.pgadmin.port}";
      };
  };
  users.users.nginx.extraGroups = ["acme"];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = config.scarisey.network.settings.email;

  security.acme.certs.${domains.root} = declareCerts domains.root;
  security.acme.certs.${domains.internal} = declareCerts domains.wildcardInternal;
  security.acme.certs.${domains.plex} = declareCerts domains.plex;
  security.acme.certs.${domains.grafana} = declareCerts domains.grafana;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [localSslPort remoteSslPort];
  };
}
