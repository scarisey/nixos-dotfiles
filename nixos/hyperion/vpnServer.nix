{...}: {
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp3s0";
  networking.nat.internalInterfaces = ["wg0"];
  networking.firewall = {
    allowedUDPPorts = [51820];
  };

  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.9.0.1/24"];
      listenPort = 51820;
      privateKeyFile = "/run/secrets/hyperion/wireguard/server/privateKey";
      peers = [
        {
          name = "lscarisey";
          publicKey = "Og8jwZqj01IavgWh3jMwbmYvC8NW2aCx9Y5LSrP6Un0=";
          allowedIPs = ["10.9.0.2/32"];
        }
        {
          name = "galaxyS25";
          publicKey = "q/QGLoPXeYdc662W/BXZs1iwSSSBkRaL4yNLu5fwDgk=";
          allowedIPs = ["10.9.0.3/32"];
        }
      ];
    };
  };
}
