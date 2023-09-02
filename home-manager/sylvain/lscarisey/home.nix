{ pkgs, lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.devtools.enable = true;
  scarisey.devtools.intellij = true;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
  ];

  home.shellAliases = {
    nixShell = "nix develop ~/git/github.com/scarisey/nixos-dotfiles -c $SHELL";
  };

}
