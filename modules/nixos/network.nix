{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.network;
in {
  options.scarisey.network.enable = mkEnableOption "Network settings";
  options.scarisey.network.systemd.enable = mkEnableOption "Use systemd network settings.";

  config = mkIf cfg.enable (mkMerge [
    {
      networking.nameservers = ["8.8.8.8" "1.1.1.1"];
      services.resolved = {
        enable = true;
        dnssec = "true";
        domains = ["~."];
        fallbackDns = [
          "8.8.4.4"
          "1.0.0.1"
        ];
        dnsovertls = "true";
      };

      environment.systemPackages = with pkgs; [
        dig
        netcat-openbsd
      ];
      programs.mtr.enable = true; #improved traceroute+ping to detect packet loss
    }

    (mkIf (!cfg.systemd.enable) {
      networking.enableIPv6 = false;
      networking.networkmanager.enable = true;
      # These options are unnecessary when managing DNS ourselves
      networking.useDHCP = false;
      networking.dhcpcd.enable = false;
    })

    (mkIf cfg.systemd.enable {
      systemd.network = {
        enable = true;
        wait-online.enable = false;

        netdevs = {
          "20-br0" = {
            netdevConfig = {
              Kind = "bridge";
              Name = "br0";
            };
          };
        };

        networks = {
          "30-enp39s0" = {
            matchConfig.Name = "enp39s0";
            networkConfig.Bridge = "br0";
            linkConfig.RequiredForOnline = "enslaved";
          };
          "40-br0" = {
            matchConfig.Name = "br0";
            bridgeConfig = {};
            networkConfig = {
              Address = "192.168.1.229/24";
              Gateway = "192.168.1.1";
            };
            linkConfig.RequiredForOnline = "no";
          };
        };
      };
    })
  ]);
}
