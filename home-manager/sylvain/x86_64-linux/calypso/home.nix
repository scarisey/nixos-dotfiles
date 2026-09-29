{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../../common.nix
  ];

  # /home is a tmpfs on this microvm: keep the age key on the persistent /data share.
  sops.age.keyFile = lib.mkForce "/data/secrets/age-keys.txt";

  scarisey.myshell.enable = true;
  scarisey.devtools = {
    enable = true;
    opencode = true;
  };

  home.packages = with pkgs; [
    gh
  ];

  sops.secrets = {
    "calypso/openrouter/demo_api_key" = {
      mode = "0400";
    };
    "calypso/relace/demo_api_key" = {
      mode = "0400";
    };
    "calypso/github/pat" = {
      mode = "0400";
    };
  };
}
