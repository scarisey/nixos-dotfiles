{config,lib,...}:
with lib; let
  cfg = config.scarisey.server;
in {
  options.scarisey.server.enable = mkEnableOption "Network settings";
  options.scarisey.server.settings = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = ''
      Keep any key value pair you want in config.scarisey.network.settings.
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    (import ./libProxy.nix)
    (import ./blocky.nix {config})
    (import ./proxy.nix {config})
    (import ./postgresql.nix {config,pkgs})
    {
      #grafana - alloy - prometheus - loki
    }
  ]);
}
