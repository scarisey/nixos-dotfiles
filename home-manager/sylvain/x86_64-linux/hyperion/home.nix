{pkgs, config, ...}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.devtools.enable = true;
  scarisey.restic = {
    enable = true;
    all = false;
    hddBackup1 = true;
  };

  sops.secrets."hyperion/wake-titan" = {
    path = "${config.home.homeDirectory}/.local/bin/wake-titan";
    mode = "0550";
  };
}
