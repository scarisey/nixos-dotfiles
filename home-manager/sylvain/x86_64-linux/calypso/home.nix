{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.devtools = {
    enable = true;
  };

  home.packages = with pkgs; [
    gh
  ];
}
