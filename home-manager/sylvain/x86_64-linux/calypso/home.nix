{
  pkgs,
  lib,
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
  };

  home.packages = with pkgs; [
    gh
  ];
}
