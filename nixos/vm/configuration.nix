{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  scarisey.server = {
    enable = true;
    settings = {
      email = "sylvain@carisey.dev";
      lanPort = 443;
      wanPort = 8443;
      ipv4 = "192.168.1.79";
      ipv6 = "fe80::291b:a25b:4e6d:5a84";
      domains = let
        rootDomain = "carisey.dev";
        internalDomain = "internal.${rootDomain}";
      in {
        root = rootDomain;
        internal = internalDomain;
        wildcardInternal = "*.${internalDomain}";
        grafana = "grafana-hyperion.${rootDomain}";
      };
      blocky = {
        clientLookup.clients.agmob = [
          "192.168.1.11"
          "fe80::54d2:b5ff:fef1:61e5"
        ];

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
