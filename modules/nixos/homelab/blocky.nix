{
  config,
  pkgs,
  ...
}: let
  localv4 = config.scarisey.homelab.settings.ipv4;
  localv6 = config.scarisey.homelab.settings.ipv6;
  domains = config.scarisey.homelab.settings.domains;
  mergedDomains = builtins.foldl' (z: x: z // x) {} (builtins.map (d: {"${d.domain}" = "${localv4},${localv6}";}) (builtins.attrValues (domains.lan // domains.public // {grafana={domain=domains.grafana;};})));
  customSettings = config.scarisey.homelab.settings.blocky;
in {
  services.blocky = {
    enable = true;
    settings =
      {
        ports.dns = 53;
        ports.http = 4000;
        bootstrapDns = [
          "https://8.8.8.8/dns-query"
        ];
        upstreams.groups.default = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.google/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
        upstreams.strategy = "parallel_best";
        upstreams.timeout = "2s";
        customDNS.mapping = mergedDomains;
        caching = {
          minTime = "5m";
          maxTime = "30m";
          prefetching = true;
        };
        prometheus = {
          enable = true;
          path = "/metrics";
        };
        log.level = "error";
        queryLog = {
          type = "postgresql";
          target = "postgres://blocky?host=/run/postgresql";
          logRetentionDays = 30;
        };
      }
      // customSettings;
  };

  networking.firewall = {
    allowedTCPPorts = [
      config.services.blocky.settings.ports.dns
    ];
    allowedUDPPorts = [
      config.services.blocky.settings.ports.dns
    ];
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "blocky";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["blocky"];
  };
}
