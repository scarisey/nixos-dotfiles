{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.bridges;
in
{
  options.scarisey.bridges = {
    enable = mkEnableOption "Network bridge";
  };

  config = mkIf cfg.enable {
    networking.interfaces.eth0.useDHCP = true;
    networking.interfaces.br0.useDHCP = true;
    networking.bridges = {
      "br0" = {
        interfaces = [ "eth0" ];
      };
    };
  };

}
