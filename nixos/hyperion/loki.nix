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
        storage = {
          filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules_chunks";
          };
        };
        replication_factor = 1;
        ring = {
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

      analytics.reporting_enabled = false;
    };
  };
}
