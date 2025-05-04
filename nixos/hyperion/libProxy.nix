{config}: let
  settings = config.scarisey.network.settings.hyperion;
in {
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
    ifLocalListen = localOnly:
      [
        {
          addr = settings.ipv4;
          port = settings.ssl.local.port;
          ssl = true;
        }
      ]
      ++ (
        if localOnly
        then []
        else [
          {
            addr = settings.ipv4;
            port = settings.ssl.remote.port;
            ssl = true;
          }
        ]
      );
  in {
    listen = ifLocalListen localOnly;
    http2 = true;
    useACMEHost =
      if localOnly
      then settings.domains.internal
      else domain;
    forceSSL = true;
  };
}
