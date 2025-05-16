{config, ...}: {
  services.scarisey.server = {
    enable = true;
    email = "sylvain@carisey.dev";
    ssl.local.port = 443;
    ssl.remote.port = 8443;
    ipv4 = "192.168.1.79";
    ipv6 = "fe80::291b:a25b:4e6d:5a84";
    domains = {
      root = "carisey.dev";
      exposed = {
        microbin = "microbin";
        jellyfin = "jellyfin";
      };
    };
    autodeclare = true;
  };

  services.blocky.settings = {
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
  services.grafana.settings.security = {
    admin_user = "admin";
    admin_password = "$__file{/run/secrets/hyperion/grafana/init_passwd}"; #only for first setup
    secret_key = "$__file{/run/secrets/hyperion/grafana/init_secret}"; #only for first setup
    allow_embedding = false;
  };

  services.postgresql.initialScript = "/run/secrets/hyperion/postgresql/init_script";
  services.pgadmin.initialPasswordFile = "/run/secrets/hyperion/pgadmin/init_passwd";
  sops = {
    secrets."hyperion/grafana/init_passwd" = {
      mode = "0440";
      group = "grafana";
    };
    secrets."hyperion/grafana/init_secret" = {
      mode = "0440";
      group = "grafana";
    };
    secrets."hyperion/pgadmin/init_passwd" = {
      mode = "0440";
      group = "pgadmin";
    };
    secrets."hyperion/postgresql/init_script" = {
      mode = "0440";
      group = "postgres";
    };
  };
}
