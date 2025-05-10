{config, ...}: let
  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts;
  declareDomains = f: domains: builtins.map (x: {services.nginx.virtualHosts.${x} = f x;}) (builtins.attrValues domains);
  exposedDomains = domains: declareDomains (x: declareVirtualHostDefaults {domain = x;}) domains;
  privateDomains = domains: declareDomains (x:
    declareVirtualHostDefaults {
      domain = x;
      localOnly = true;
    })
  domains;
in (exposedDomains config.services.scarisey.server.domains.exposed) // (privateDomains config.services.scarisey.server.domains.private)

