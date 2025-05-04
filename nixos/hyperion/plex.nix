{config, ...}: let
  domains = config.scarisey.network.settings.hyperion.domains;
  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts;
in {
  services.plex.enable = true;
  users.users.plex.extraGroups = ["users"];
  services.nginx.virtualHosts.${domains.plex} =
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

  security.acme.certs.${domains.plex} = declareCerts domains.plex;
}
