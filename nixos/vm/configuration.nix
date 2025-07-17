{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
    ./microbin.nix
  ];

  virtualisation = {
    diskSize = 65536;
  };

  scarisey.homelab = {
    enable = true;
    settings = {
      email = "sylvain@carisey.dev";
      lanPort = 443;
      wanPort = 8443;
      ipv4 = "10.0.2.15";
      ipv6 = "fe80::5054:ff:fe12:3456";
      domains = let
        rootDomain = "carisey.dev";
        internalDomain = "internal.${rootDomain}";
      in {
        root = rootDomain;
        internal = internalDomain;
        wildcardInternal = "*.${internalDomain}";
        grafana = "grafana-vm.${rootDomain}";
        public = {
          jellyfin = {
            domain = "jellyfin.${rootDomain}";
            proxyPass = "http://localhost:8096";
          };
        };
        lan = {
          microbin ={
            domain = "microbin.${internalDomain}";
            proxyPass = "http://127.0.0.1:8080$request_uri";
          };
        };
      };
      grafana = {
        security = {
          admin_user = "admin";
          admin_password = "grafana"; #only for first setup
          secret_key = "grafana_secret"; #only for first setup
        };
      };
      blocky = {
        blocking = {
          blockType = "zeroIP";
          denylists = {
            ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
            fakenews = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"];
          };
          clientGroupsBlock = {
            default = ["ads" "fakenews"];
            agmob = ["fakenews"];
          };
        };
      };
    };
  };

  users.users.sylvain.password = "nixos";

  services.jellyfin.enable = true;

  networking.hostName = "vm";
  sops = {
    defaultSopsFile = "${inputs.private-vault}/secrets.yaml";
    age.keyFile = "/home/sylvain/.config/sops/age/keys.txt";
    secrets."hyperion/samba/freebox" = {};
    secrets."hyperion/grafana/init_passwd" = {
      mode = "0440";
      group = "grafana";
    };
    secrets."hyperion/grafana/init_secret" = {
      mode = "0440";
      group = "grafana";
    };
    secrets."hyperion/postgresql/grafana_grants" = {
      mode = "0440";
      group = "postgres";
    };
    secrets."hyperion/microbin/passwordFile" = {
      mode = "0440";
      group = "microbin-sec";
    };
  };
}
