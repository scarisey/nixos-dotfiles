{...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      ports.http = 4000;
      upstreams.groups.default = [
        "1.1.1.1"
        "8.8.8.8"
        "9.9.9.9"
      ];
      upstreams.strategy = "parallel_best";
      upstreams.timeout = "2s";
      connectIPVersion = "v4";
      customDNS.mapping = {
        "plex-hyperion.carisey.dev" = "192.168.1.79";
        "grafana-hyperion.carisey.dev" = "192.168.1.79";
        "zoneminder-hyperion.carisey.dev" = "192.168.1.79";
        "cockpit-hyperion.carisey.dev" = "192.168.1.79";
      };

      blocking = {
        blockType = "zeroIP";
        denylists = {
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        };
        clientGroupsBlock = {
          default = ["ads"];
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
    };
  };

  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
}
