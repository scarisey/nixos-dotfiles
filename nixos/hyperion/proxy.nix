{config, ...}: let
  mydomain = "carisey.dev";
in {
  services.nginx = {
    enable = true;
    # we can use the main domain or any subdomain that's mentioned by
    # "extraDomainNames" in the acme certificate.
    virtualHosts."home.${mydomain}" = {
      # 3. Instead of "enableACME = true;" we
      # reuse the certificate from "security.acme.certs."example.org"
      # down below
      useACMEHost = mydomain;
      forceSSL = true;
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
    };
  };

  users.users.nginx.extraGroups = ["acme"];

  scarisey.acme = {
    enable = true;
    email = "sylvain@${mydomain}";
    domain = mydomain;
    dnsProvider = "ionos";
    credentialsFile = "/var/ionos/token";
  };
}
