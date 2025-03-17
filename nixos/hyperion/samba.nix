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
        };
        public = {
          browseable = "yes";
          "read only" = "yes";
          "guest ok" = "yes";
          path = "/data/Public";
          comment = "Hello World!";
          public = "yes";
        };
      };
    };
  };

  #mount shares
  environment.systemPackages = [pkgs.cifs-utils];
  fileSystems."/mnt/freebox" = {
    device = "//192.168.1.254/Volume 1024Go 1/";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/run/secrets/hyperion/samba/freebox"];
  };
}
