{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  home.packages = with pkgs;[
    gh
  ];
}
