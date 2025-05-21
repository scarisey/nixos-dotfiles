{pkgs, ...}: {
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
  scarisey.devtools.android = true;
  scarisey.gnome.enable = true;

  home.packages = with pkgs; [
    protonvpn-gui
    picard
    windsurf
  ];
}
