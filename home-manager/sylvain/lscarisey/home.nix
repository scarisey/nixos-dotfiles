{ pkgs, lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.devtools = {
    enable = true;
    all = true;
  };
  scarisey.quickemu.enable = true;
  scarisey.cloud.all = true;
  scarisey.cloud.enable = true;
  scarisey.kde.enable = true;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
  ];

}
