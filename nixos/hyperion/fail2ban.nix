{...}: {
  services.fail2ban = {
    enable = true;
    jails.grafana = {
      enabled = true;
      settings = {
        filter = "grafana";
        journalmatch = "_SYSTEMD_UNIT=grafana.service";
        maxretry = 3;
        bantime = "1h";
        findtime = "10m";
        port = "3000";
        action = "iptables[name=Grafana, port=3000, protocol=tcp]";
      };
    };
    jails.zoneminder = {
      enabled = true;
      settings = {
        filter = "zoneminder";
        journalmatch = "_SYSTEMD_UNIT=zoneminder.service";
        maxretry = 3;
        bantime = "1h";
        findtime = "10m";
        port = "3000";
        action = "iptables[name=zoneminder, port=8085, protocol=tcp]";
      };
    };
  };
}
