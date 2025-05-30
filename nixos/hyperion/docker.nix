{config,lib,...}:let
  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts domains;
in {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = "overlay2";
    autoPrune = {
      enable = true;
      dates = "Fri *-*-* 05:00:00";
    };
  };

  services.nginx.virtualHosts."${domains.wildcardHeimdall}" =
    declareVirtualHostDefaults {
      domain = domains.heimdall;
      localOnly = true;
    }
    // {
      useACMEHost = lib.mkForce domains.heimdall;
      locations."/".proxyPass = "http://localhost:7080";
    };

  security.acme.certs.${domains.heimdall} = declareCerts domains.wildcardHeimdall;
}
