{...}: {
  services.loki = {
    enable = true;

    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9095;
      };

      common = {
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring = {
          instance_addr= "127.0.0.1";
          kvstore.store = "inmemory";
        };
      };

      schema_config = {
        configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config.filesystem.directory = "/var/lib/loki/chunks";

      analytics.reporting_enabled = false;
    };
  };
}
