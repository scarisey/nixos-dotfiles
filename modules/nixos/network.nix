{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.network;
in
{
  options.scarisey.network.enable = mkEnableOption "Network settings";
  options.scarisey.network.bridges.enable = mkEnableOption "Network bridge";

  config = mkIf cfg.enable (mkMerge [
    {
      networking.networkmanager.enable = true;
      networking.nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" "208.67.222.222" ];
      services.resolved = {
        enable = true;
        fallbackDns = [ "8.8.8.8" "1.1.1.1"];
      };

      environment.systemPackages = with pkgs;[
        dig
        netcat-openbsd
      ];
    }

    (mkIf cfg.bridges.enable {
      networking.interfaces.enp39s0.useDHCP = true;
      networking.interfaces.br0.useDHCP = true;
      networking.bridges = {
        "br0" = {
          interfaces = [ "enp39s0" ];
        };
      };
    }
    )
  ]);

}
