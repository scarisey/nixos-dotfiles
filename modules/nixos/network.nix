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
      environment.systemPackages = with pkgs; [
        dig
        netcat-openbsd
      ];
      programs.mtr.enable = true; #improved traceroute+ping to detect packet loss
    }

  ]);
}
