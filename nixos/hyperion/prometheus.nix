{config, ...}: {
  services.prometheus = {
    enable = true;
    port = 9091;
    listenAddress = "127.0.0.1";
    retentionTime = "30d";

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
              "${config.services.prometheus.exporters.process.listenAddress}:${toString config.services.prometheus.exporters.process.port}"
              "${config.services.prometheus.exporters.nginx.listenAddress}:${toString config.services.prometheus.exporters.nginx.port}"
              "127.0.0.1:${toString config.services.blocky.settings.ports.http}"
            ];
          }
        ];
      }
    ];
  };
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    listenAddress = "127.0.0.1";
    enabledCollectors = [
      "logind"
      "systemd"
      "processes"
    ];
  };
  services.prometheus.exporters.process = {
    enable = true;
    port = 9101;
    listenAddress = "127.0.0.1";
    settings.process_names = [
      {
        name = "{{.Matches.Wrapped}} {{ .Matches.Args }}";
        cmdline = ["^/nix/store[^ ]*/(?P<Wrapped>[^ /]*) (?P<Args>.*)"];
      }
    ];
  };

  services.prometheus.exporters.nginx = {
    enable = true;
    port = 9102;
    listenAddress = "127.0.0.1";
    scrapeUri = "http://localhost/nginx_status";
  };
}
