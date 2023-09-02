{ pkgs, lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.devtools.enable = true;
  scarisey.devtools.intellij = true;
  scarisey.i3 = {
    enable = true;
    browserPath = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };

}
