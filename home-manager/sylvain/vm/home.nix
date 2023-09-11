{ pkgs, lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.devtools.enable = false;
  scarisey.devtools.intellij = false;
  scarisey.i3Xfce.enable = false;

}
