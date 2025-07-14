args @ {lib, ...}:
with lib; {
  config = mkMerge [
    (import ./alloy.nix args)
    (import ./grafana.nix args)
    (import ./loki.nix args)
    (import ./prometheus.nix args)
  ];
}
