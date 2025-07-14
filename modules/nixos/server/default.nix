args @ {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.scarisey.server;
  libProxy = import ./libProxy.nix {inherit config;};
  enrichedArgs = args // {lib = args.lib // libProxy;};
  allConfig = {
    options = import ./options.nix enrichedArgs;

    config = mkIf cfg.enable (mkMerge [
      (import ./blocky.nix enrichedArgs)
      (import ./proxy.nix enrichedArgs)
      (import ./postgresql.nix enrichedArgs)
      (import ./monitoring/default.nix enrichedArgs)
    ]);
  };
in
  allConfig
