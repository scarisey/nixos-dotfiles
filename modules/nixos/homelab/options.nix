{
  lib,
  config,
  ...
}: let
  cfg = config.scarisey.homelab;
  customDomainType = with lib; types.submodule {
    options = {
      domain = mkOption {
        type = types.str;
        description = "Full domain for this service.";
      };
      proxyPass = mkOption {
        type = types.str;
        description = "URL to the service (localhost).";
      };
    };
  };
in
  with lib; {
    scarisey.homelab = {
      enable = mkEnableOption "Server settings";
      settings.email = mkOption {
        type = types.str;
        description = "Email address used by Let's Encrypt.";
      };
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
      settings.domains = mkOption {
        description = "Domains declaration.";
        default = {};
        type = types.submodule {
          options = {
            root = mkOption {
              type = types.str;
              description = "Shared root domain by all domains declared.";
            };
            internal = mkOption {
              type = types.str;
              description = "Used prefix for internal domains.";
              default = "internal.${cfg.settings.domains.root}";
            };
            wildcardInternal = mkOption {
              type = types.str;
              description = "Wild internal domain to generate a common SSL certificate.";
              default = "*.${cfg.settings.domains.internal}";
            };
            grafana = mkOption {
              type = types.str;
              description = "grafana domain, will be exposed on LAN and WAN by default.";
              default = "grafana.${cfg.settings.domains.root}";
            };
            lan = mkOption {
              type = types.attrsOf customDomainType;
              default = {};
              description = "Attribute set of domains accessible only on LAN.";
            };
            public = mkOption {
              type = types.attrsOf customDomainType;
              default = {};
              description = "Attribute set of domains accessible on LAN and WAN.";
            };
          };
        };
      };
      settings.blocky = mkOption {
        description = "Blocky settings to merge to defaults.";
        default = {};
        type = types.attrsOf types.anything;
      };
      settings.grafana = mkOption {
        description = "Grafana settings to merge to defaults.";
        default = {};
        type = types.attrsOf types.anything;
      };
    };
  }
