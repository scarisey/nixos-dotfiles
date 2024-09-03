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

  config = mkIf cfg.enable (mkMerge [
    {
      networking.enableIPv6 = false;
      networking.networkmanager.enable = true;
      networking.nameservers = ["8.8.8.8" "192.168.1.1" "8.8.4.4" "1.1.1.1"];
      # These options are unnecessary when managing DNS ourselves
      networking.useDHCP = false;
      networking.dhcpcd.enable = false;

      environment.systemPackages = with pkgs; [
        dig
        netcat-openbsd
      ];
      programs.mtr.enable = true; #improved traceroute+ping to detect packet loss
    }
  ]);
}
