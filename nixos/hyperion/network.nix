{pkgs, ...}: {
  scarisey.network.enable = true;
  scarisey.vpn = {
    enable = false;
    confPath = "/run/secrets/hyperion/vpn";
    openFirewall = true;
  };
  services.gnome.gnome-remote-desktop.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
  services.xrdp.openFirewall = true;
  networking.firewall = {
    allowedTCPPorts = [139 145 5357 8080 3389]; #SAMBA QBITTORENT RDP
    allowedUDPPorts = [137 138 3702];
    connectionTrackingModules = ["netbios_sn"];
  };

  environment.systemPackages = [pkgs.gnome-remote-desktop];
}
