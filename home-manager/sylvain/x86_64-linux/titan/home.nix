{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.gui.obs = true;
  scarisey.devtools.enable = true;
  scarisey.devtools.all = true;
  scarisey.devtools.vscode = true;
  scarisey.devtools.intellij = true;
  scarisey.gnome.enable = true;
  scarisey.quickemu.enable = true;

  home.packages = with pkgs; [
    nix-alien
    protonvpn-gui
  ];
}
