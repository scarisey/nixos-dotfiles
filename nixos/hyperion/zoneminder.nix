{...}: {
  services.zoneminder = {
    enable = true;
    storageDir = "/data/disk1/zoneminder";
    webserver = "none";
    port = 8095;
    openFirewall = false;
    hostname = "localhost";
    cameras = 1;
    database = {
      createLocally = true;
      username = "zoneminder";
    };
  };
}
