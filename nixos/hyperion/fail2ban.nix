{...}: {
  services.fail2ban = {
    enable = true;
    jails.grafana.enabled = true;
    jails.zoneminder.enabled = true;
    # jails.plex = {
    #   enabled = true;
    #   settings = {
    #     filter = "plex";
    #     journalmatch = "_SYSTEMD_UNIT=plexmediaserver.service";
    #     maxretry = 3;
    #     bantime = "1h";
    #     findtime = "10m";
    #     port = "3000";
    #     action = "iptables[name=Plex, port=32400, protocol=tcp]";
    #   };
    #   filter =  {
    #     Definition = {
    #         failregex = "^.*Authentication failed for user.*$";
    #         ignoreregex = "";
    #     };
    #   };
    # };
  };
}
