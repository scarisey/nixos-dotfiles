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
    openFirewall = mkEnableOption "Open WG port";
    port = mkOption {
      type = lib.types.port;
      default = 51820;
      example = 51820;
      description = "WireGuard port";
    };

    confPath = mkOption {
      type = lib.types.path;
      default = "/var/lib/protonvpn/my.conf";
      example = "/var/lib/protonvpn/my.conf";
      description = "Path to the vpn configuration.";
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        networking.wg-quick.interfaces.wg0 = {
          autostart = true;
          configFile = cfg.confPath;
        };
        systemd.services.wg-quick-wg0.after = ["sops-nix.service"];
      }

      (mkIf cfg.openFirewall {
        networking.firewall = {
          allowedUDPPorts = [cfg.port];
        };
      })
    ]
  );
}
