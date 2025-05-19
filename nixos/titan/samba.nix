{
  pkgs,
  config,
  ...
}: {
  services = {
    gvfs.enable = true;
    avahi = {
      publish.enable = true;
      publish.userServices = true;
      enable = true;
      openFirewall = true;
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    samba = {
      #For a user called my_userto be authenticated on the samba server, you must add their password using
      #smbpasswd -a someUser
      package = pkgs.samba4Full;
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "server smb encrypt" = "desired";
          # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
          "server min protocol" = "SMB3_00";
          "security" = "user";
          "map to guest" = "bad user";
          "guest account" = "nobody";
          "local master" = "yes";
          "preferred master" = "yes";
          "domain master" = "yes";
          "os level" = "255";
        };
        public = {
          browseable = "yes";
          "read only" = "yes";
          "guest ok" = "yes";
          path = "/data/Public";
          comment = "Hello World!";
          public = "yes";
        };
        shared = {
          browseable = "yes";
          path = "/data/shared";
          "write list" = "sylvain";
        };
      };
    };
  };
}
