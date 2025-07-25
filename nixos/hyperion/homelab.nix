{...}:{
  services.jellyfin.enable = true;
  scarisey.homelab = {
    enable = true;
    settings = {
      email = "sylvain@carisey.dev";
      lanPort = 443;
      wanPort = 8443;
      ipv4 = "192.168.1.79";
      ipv6 = "fe80::291b:a25b:4e6d:5a84";
      domains = let
        rootDomain = "carisey.dev";
        internalDomain = "internal.${rootDomain}";
      in {
        root = rootDomain;
        internal = internalDomain;
        wildcardInternal = "*.${internalDomain}";
        grafana = "grafana-hyperion.${rootDomain}";
        public = {
          jellyfin = {
            domain = "jellyfin.${rootDomain}";
            proxyPass = "http://localhost:8096";
          };
          microbin ={
            domain = "microbin.${internalDomain}";
            proxyPass = "http://127.0.0.1:8080$request_uri";
          };
        };
        lan = { };
      };
      grafana = {
        security = {
          admin_user = "admin";
          admin_password = "grafana"; #only for first setup
          secret_key = "grafana_secret"; #only for first setup
        };
      };
      blocky = {
        clientLookup.clients.agmob = [
          "192.168.1.11"
          "fe80::54d2:b5ff:fef1:61e5"
        ];
        blocking = {
          blockType = "zeroIP";
          denylists = {
            ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
            fakenews = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"];
          };
          clientGroupsBlock = {
            default = ["ads" "fakenews"];
            agmob = ["fakenews"];
          };
        };
      };
    };
  };
}
