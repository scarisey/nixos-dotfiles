{pkgs, ...}: {
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
        };
        public = {
          browseable = "yes";
          "read only" = "yes";
          "guest ok" = "yes";
          path = "/data/Public";
          comment = "Hello World!";
          public = "yes";
        };
        private = {
          browseable = "yes";
          writeable = "yes";
          path = "home/sylvain/private";
        };
        musique = {
          browseable = "yes";
          writeable = "no";
          path = "/mnt/medias/Musique";
        };
        downloads = {
          browseable = "yes";
          writeable = "no";
          path = "/mnt/medias/Downloads";
        };
      };
    };
  };
}
