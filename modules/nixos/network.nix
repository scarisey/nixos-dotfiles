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
  options.scarisey.network.settings = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = ''
      Keep any key value pair you want in config.scarisey.network.settings.
    '';
  };

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
