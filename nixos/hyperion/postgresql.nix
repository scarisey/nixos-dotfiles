{
  pkgs,
  config,
  ...
}: let
  libProxy = import ./libProxy.nix {inherit config;};
  inherit (libProxy) declareVirtualHostDefaults declareCerts domains;
in {
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql_17;
    ensureUsers = [
      {
        name = "pgadmin";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["pgadmin"];
    authentication = ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     peer
      host    all             all             127.0.0.1/32            scram-sha-256
    '';

    settings = {
      listen_addresses = "localhost";
      password_encryption = "scram-sha-256";
      log_connections = true;
      log_disconnections = true;
      log_statement = "none";
      log_line_prefix = "%m [%p] %u@%d ";
      client_min_messages = "notice";
      shared_buffers = "512MB";
      jit = true;
      track_io_timing = true;
    };

    initialScript = "/run/secrets/hyperion/postgresql/init_script";
  };

  #PGADMIN

  services.pgadmin = {
    enable = true;
    port = 5050;
    initialEmail = config.scarisey.network.settings.email;
    initialPasswordFile = "/run/secrets/hyperion/pgadmin/init_passwd";
  };

  services.nginx.virtualHosts.${domains.pgadmin} =
    declareVirtualHostDefaults {
      domain = domains.pgadmin;
      localOnly = true;
    }
    // {
      locations."/".proxyPass = "http://localhost:${toString config.services.pgadmin.port}";
    };
}
