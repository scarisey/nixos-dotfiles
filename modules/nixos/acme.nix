{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.acme;
in {
  options.scarisey.acme = {
    enable = mkEnableOption "Acme config";
    email = mkOption {
      example = "info@example.org";
      type = lib.types.str;
      description = "User's mail";
    };
    domain = mkOption {
      example = "example.org";
      type = lib.types.str;
      description = "Domain";
    };
    dnsProvider = mkOption {
      example = "hetzner";
      type = lib.types.str;
      description = "DNS provider";
    };
    credentialsFile = mkOption {
      example = "config.age.secrets." hetzner-dns-token.age ".path";
      type = lib.types.path;
      description = "Credentials file";
    };
    extraDomainNames = mkOption {
      default = [];
      type = lib.types.listOf lib.type.str;
      description = "Subdomains";
    };
  };

  config = mkIf cfg.enable {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.email;

    # 2. Let NixOS generate a Let's Encrypt certificate that we can reuse
    # above for several virtualhosts above.
    security.acme.certs.${cfg.domain} = {
      domain = cfg.domain;
      extraDomainNames = ["subdomain.example.org"];
      # The LEGO DNS provider name. Depending on the provider, need different
      # contents in the credentialsFile below.
      dnsProvider = cfg.dnsProvider;
      dnsPropagationCheck = true;
      # agenix will decrypt our secrets file (below) on the server and make it available
      # under /run/agenix/secrets/hetzner-dns-token (by default):
      # credentialsFile = "/run/agenix/secrets/hetzner-dns-token";
      credentialsFile = cfg.credentialsFile;
    };
  };
}
