{...}: {
  services.zoneminder = {
    enable = true;
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
