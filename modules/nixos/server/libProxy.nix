{config, ...}: {
  libProxy = {
    declareCerts = domain: {
      inherit domain;
      #check https://go-acme.github.io/lego/dns/
      dnsProvider = "ionos";
      dnsPropagationCheck = true;
      environmentFile = "/var/ionos/token";
      group = "acme";
    };

    declareVirtualHostDefaults = {
      domain,
      localOnly ? false,
    }: let
      ipv4 = config.scarisey.server.settings.ipv4;
      lanPort = config.scarisey.server.settings.lanPort;
      wanPort = config.scarisey.server.settings.wanPort;
      ifLocalListen = localOnly:
        [
          {
            addr = ipv4;
            port = lanPort;
            ssl = true;
          }
        ]
        ++ (
          if localOnly
          then []
          else [
            {
              addr = ipv4;
              port = wanPort;
              ssl = true;
            }
          ]
        );
    in {
      listen = ifLocalListen localOnly;
      http2 = true;
      useACMEHost = domain;
      forceSSL = true;
    };
  };
}
