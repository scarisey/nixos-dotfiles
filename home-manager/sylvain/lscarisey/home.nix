{ pkgs, lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  targets.genericLinux.enable = true;

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.gui.obs = true;
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
    keepassxc
  ];

}
