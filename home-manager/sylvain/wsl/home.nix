{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
}
