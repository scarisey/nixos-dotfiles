{
  config,
  lib,
  ...
}: let
  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts;
in {
  autoDeclareDomains = {}: let
    settings = config.services.scarisey.server;
    exposedDomains = domains:
      lib.pipe domains [
        (builtins.attrValues)
        (map (x: "${x}.${settings.domains.root}"))
        (builtins.map (x: {
          services.nginx.virtualHosts.${x} = declareVirtualHostDefaults {domain = x;};
          security.acme.certs.${x} = declareCerts x;
        }))
      ];
    privateDomains = domains:
      lib.pipe domains [
        (builtins.attrValues)
        (map (x: "${x}.${settings.domains.internal}") domains)
        (builtins.map (x: {
          services.nginx.virtualHosts.${x} = declareVirtualHostDefaults {
            domain = x;
            localOnly = true;
          };
        }))
      ];
  in
    (exposedDomains settings.domains.exposed) ++ (privateDomains settings.domains.private);
}
