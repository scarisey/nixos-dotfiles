{pkgs, ...}: {
  scarisey.network.enable = true;
  systemd.services.wg-quick-wg0.after = ["sops-nix.service"];
  scarisey.vpn = {
    enable = true;
    confPath = "/run/secrets/hyperion/vpn";
    openFirewall = true;
  };
  services.gnome.gnome-remote-desktop.enable = true;

  networking.firewall = {
    allowedTCPPorts = [139 145 5357 8080 3389]; #SAMBA QBITTORENT RDP
    allowedUDPPorts = [137 138 3702];
    connectionTrackingModules = ["netbios_sn"];
  };
}
