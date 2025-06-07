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
    secrets."hyperion/pgadmin/init_passwd" = {
      mode = "0440";
      group = "pgadmin";
    };
    secrets."hyperion/postgresql/init_script" = {
      mode = "0440";
      group = "postgres";
    };
    secrets."hyperion/microbin/passwordFile" = {
      mode = "0440";
      group = "microbin-sec";
    };
  };
}
