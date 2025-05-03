{
  config,
  pkgs,
  ...
}: let
  localv4 = config.scarisey.network.settings.hyperion.ipv4;
  localv6 = config.scarisey.network.settings.hyperion.ipv6;
  domains = config.scarisey.network.settings.hyperion.domains;
in {
  services.blocky = {
    enable = true;
    settings = {
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
      customDNS.mapping = {
        "${domains.plex}" = "${localv4},${localv6}";
        "${domains.grafana}" = "${localv4},${localv6}";
        "${domains.pgadmin}" = "${localv4},${localv6}";
      };
      clientLookup.clients.agmob = [
        "192.168.1.11"
        "fe80::54d2:b5ff:fef1:61e5"
      ];

      blocking = {
        blockType = "zeroIP";
        denylists = {
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
          fakenews = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"];
        };
        clientGroupsBlock = {
          default = ["ads" "fakenews"];
          agmob = ["fakenews"];
        };
      };
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
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      config.services.blocky.settings.ports.dns
    ];
    allowedUDPPorts = [
      config.services.blocky.settings.ports.dns
    ];
  };
}
