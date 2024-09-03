{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.vpn;
in {
  options.scarisey.vpn = {
    enable = mkEnableOption "VPN config.";
    confPath = mkOption {
      type = lib.types.path;
      default = "/var/lib/protonvpn/my.conf";
      example = "/var/lib/protonvpn/my.conf";
      description = "Path to the vpn configuration.";
    };
  };

  config = mkIf cfg.enable {
    networking.wg-quick.interfaces.wg0 = {
      autostart = true;
      configFile = cfg.confPath;
    };
    environment.systemPackages = with pkgs; [
      openport
    ];
  };
}
