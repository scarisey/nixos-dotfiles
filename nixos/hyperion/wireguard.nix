{...}:{
  networking.wg-quick.interfaces.wg0 = {
    autostart = true;
    configFile = "/var/lib/vpn/hyperion.conf";
  };
}
