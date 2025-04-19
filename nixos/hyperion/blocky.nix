{...}: let
  localv4 = "192.168.1.79";
  localv6 = "fe80::291b:a25b:4e6d:5a84";
in {
  services.blocky = {
    enable = true;
    settings = {
      log.level="error";
      ports.dns = 53;
      ports.http = 4000;
      upstreams.groups.default = [
        "1.1.1.1"
        "8.8.8.8"
        "9.9.9.9"
        "2606:4700:4700:0:0:0:0:1111"
        "2001:4860:4860:0:0:0:0:8888"
      ];
      upstreams.strategy = "parallel_best";
      upstreams.timeout = "2s";
      customDNS.mapping = {
        "plex-hyperion.carisey.dev" = "${localv4},${localv6}";
        "grafana-hyperion.carisey.dev" = "${localv4},${localv6}";
        "zoneminder-hyperion.internal.carisey.dev" = "${localv4},${localv6}";
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
