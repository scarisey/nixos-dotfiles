{config, ...}: {
  services.prometheus = {
    enable = true;
    port = 9091;
    listenAddress = "127.0.0.1";

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
              "${config.services.prometheus.exporters.process.listenAddress}:${toString config.services.prometheus.exporters.process.port}"
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
}
