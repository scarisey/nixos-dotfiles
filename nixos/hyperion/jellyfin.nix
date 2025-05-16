{config, ...}: let
  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts domains;
in {
  services.jellyfin = {
    enable = true;
  };

  services.nginx.virtualHosts.${domains.jellyfin} =
    declareVirtualHostDefaults {domain = domains.jellyfin;}
    // {
      locations."/".proxyPass = "http://localhost:8096";
    };
  security.acme.certs.${domains.jellyfin} = declareCerts domains.jellyfin;
}
