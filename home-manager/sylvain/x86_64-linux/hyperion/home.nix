{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.devtools.enable = true;
  scarisey.autoUpdate = {
    enable = true;
    dates = "Fri *-*-* 04:30:00";
    flake = "github:scarisey/nixos-dotfiles";
  };
}
