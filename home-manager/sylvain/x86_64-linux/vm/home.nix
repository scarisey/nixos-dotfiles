{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
}
