{...}: {
  services.zoneminder = {
    enable = true;
    openFirewall = true;
    webserver = "nginx";
    hostname = "localhost";
    port = 8085;
    database = {
      createLocally = true;
      name = "zm";
      username = "zoneminder";
    };
  };
}
