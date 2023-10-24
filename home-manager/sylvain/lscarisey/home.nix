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

  home.packages = with pkgs; [
    nixgl.nixGLIntel
  ];

}
