{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.scarisey.server;
in {
  options.services.scarisey.server = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the scarisey server.";
    };

    email = mkOption {
      type = types.str;
      description = "Admin email address for the server.";
    };

    ssl = {
      local.port = mkOption {
        type = types.port;
        default = 443;
        description = "Local SSL port.";
      };

      remote.port = mkOption {
        type = types.port;
        default = 8443;
        description = "Remote SSL port.";
      };
    };

    ipv4 = mkOption {
      type = types.str;
      description = "IPv4 address of the server.";
    };

    ipv6 = mkOption {
      type = types.str;
      description = "IPv6 address of the server.";
    };

    domains.root = mkOption {
      type = types.str;
      description = "root domain";
    };
    domains.internal = mkOption {
      type = types.str;
      description = "internal domain";
    };
    domains.wildcardInternal = mkOption {
      type = types.str;
      description = "internal wildcard domain";
    };
    domains.grafana = mkOption {
      type = types.str;
      description = "grafana domain";
    };
    domains.pgadmin = mkOption {
      type = types.str;
      description = "pgadmin domain";
    };
    domains.exposed = mkOption {
      type = types.attrsOf types.str;
      description = "Services exposed to root domain";
      default = {};
    };
    domains.private = mkOption {
      type = types.attrsOf types.str;
      description = "Services exposed to internal domain only";
      default = {};
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      imports = [
        ./alloy.nix
        ./autodeclare.nix
        ./blocky.nix
        ./grafana.nix
        ./loki.nix
        ./postgresql.nix
        ./prometheus.nix
        ./proxy.nix
      ];
      assertions = [
        {
          assertion = cfg.domains ? root;
          message = "services.scarisey.server.domains must define 'root' domain.";
        }
      ];
      services.scarisey.server.domains.internal = mkDefault "internal.${cfg.domains.root}";
      services.scarisey.server.domains.wildcardInternal = mkDefault "*.${cfg.domains.internal}";
      services.scarisey.server.domains.pgadmin = mkDefault "pgadmin.${cfg.domains.internal}";
      services.scarisey.server.domains.grafana = mkDefault "grafana.${cfg.domains.root}";
    }
  ]);
}
