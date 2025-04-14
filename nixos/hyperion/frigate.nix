{config, ...}: {
  services.frigate = {
    enable = true;
    hostname = config.scarisey.network.settings.hyperion.domains.frigate;
  };
}
