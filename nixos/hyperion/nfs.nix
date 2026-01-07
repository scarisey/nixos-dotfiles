{...}: {
  services.nfs.server = {
    enable = true;
    exports = ''
      /data/shared 192.168.1.0/24
    '';
  };
  networking.firewall.allowedTCPPorts = [2049];
}
