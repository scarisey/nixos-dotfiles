{ pkgs, lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.devtools.enable = true;
  scarisey.devtools.all = true;
  scarisey.quickemu.enable = true;

}
