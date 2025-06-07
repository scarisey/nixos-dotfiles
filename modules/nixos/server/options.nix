{lib,config,...}:let
  cfg = config.scarisey.server;
in with lib;{
  options.scarisey.server = {
    enable = mkEnableOption "Server settings";
    settings.ipv4 = mkOption {
      type = types.str;
      description = "IPv4 in your LAN where the server is.";
    };
    settings.ipv6 = mkOption {
      type = types.str;
      description = "IPv6 in your LAN where the server is.";
    };
    settings.wanPort = mkOption {
      type = types.port;
      description = "If your server is behing a NAT, port by which the Internet traffic comes from.";
    };
    settings.lanPort = mkOption {
      type = types.port;
      description = "If your server is behing a NAT, port by which the LAN traffic comes from.";
    };
    settings.domains.root = mkOption {
      type = types.str;
      description = "Shared root domain by all domains declared.";
    };
    settings.domains.internal = mkOption {
      type = types.str;
      description = "Used prefix for internal domains.";
      default = "internal.${cfg.settings.domains.root}"
    };
    settings.domains.wildcardInternal = mkOption {
      type = types.str;
      description = "Wild internal domain to generate a common SSL certificate.";
      default = "*.${cfg.settings.domains.internal}"
    };
    settings.domains.pgadmin = mkOption {
      type = types.str;
      description = "pgadmin domain, will be exposed only on LAN by default.";
      default = "pgadmin.${cfg.settings.domains.internal}"
    };
    settings.domains.grafana = mkOption {
      type = types.str;
      description = "grafana domain, will be exposed on LAN and WAN by default.";
      default = "grafana.${cfg.settings.domains.root}"
    };
    settings.domains.lan = mkOption {
      type = types.attrs;
      default = {};
      example = litteralExpression ''
      {
        grafana1 = "grafana-1"; #would resolve to grafana-1.{settings.domains.root}
        grafana2 = "grafana-2"; #would resolve to grafana-2.{settings.domains.root}
      }
      '';
      description = "Attribute set of domains accessible only on LAN.";
    };
    settings.domains.public = mkOption {
      type = types.attrs;
      default = {};
      example = litteralExpression ''
      {
        grafana1 = "grafana-1"; #would resolve to grafana-1.{settings.domains.root}
        grafana2 = "grafana-2"; #would resolve to grafana-2.{settings.domains.root}
      }
      '';
      description = "Attribute set of domains accessible on LAN and WAN.";
    };
  };
}
