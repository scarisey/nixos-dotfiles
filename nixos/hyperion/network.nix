{
  pkgs,
  config,
  ...
}: let
  rootDomain = "carisey.dev";
  internalDomain = "internal.${rootDomain}";
in {
  scarisey.network = {
    enable = true;
    settings = {
      email = "sylvain@carisey.dev";
      hyperion = {
        ssl.local.port = 443;
        ssl.remote.port = 8443;
        ipv4 = "192.168.1.79";
        ipv6 = "fe80::291b:a25b:4e6d:5a84";
        domains = {
          root = "carisey.dev";
          internal = "internal.${rootDomain}";
          wildcardInternal = "*.${internalDomain}";
          grafana = "grafana-hyperion.${rootDomain}";
          microbin = "microbin.${rootDomain}";
          jellyfin = "jellyfin.${rootDomain}";
        };
      };
    };
  };
  networking.firewall = {
    connectionTrackingModules = ["netbios_sn"];
  };
}
