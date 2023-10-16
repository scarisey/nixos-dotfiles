{ pkgs, lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.devtools.enable = true;
  scarisey.devtools.all = true;
  scarisey.quickemu.enable = true;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
  ];

  home.file."fhs.nix".source = ./fhs.nix;

  home.shellAliases = {
    nixShell = "nix-shell $HOME/fhs.nix";
  };

}
