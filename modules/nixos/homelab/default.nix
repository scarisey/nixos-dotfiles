args @ {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.scarisey.homelab;
  libProxy = import ./libProxy.nix {inherit config;};
  enrichedArgs = args // {lib = args.lib // libProxy;};
  allConfig = {
    options = import ./options.nix enrichedArgs;

    config = mkIf cfg.enable (mkMerge (
      builtins.map (file: import file enrichedArgs) [
        ./blocky.nix
        ./proxy.nix
        ./postgresql.nix
        ./monitoring/loki.nix
        ./monitoring/prometheus.nix
        ./monitoring/grafana.nix
        ./monitoring/alloy.nix
      ]
    ));
  };
in
  allConfig
