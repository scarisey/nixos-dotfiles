{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;

  # Test de migration nixvim (voir modules/home-manager/nvim-nixvim.nix) :
  # myshell.enable force scarisey.nvim.enable = true, on le désactive ici
  # pour n'avoir que le module nixvim actif (mutuellement exclusifs).
  scarisey.nvim.enable = lib.mkForce false;
  scarisey.nvim-nixvim.enable = true;

  home.packages = with pkgs; [
    gh
  ];
}
