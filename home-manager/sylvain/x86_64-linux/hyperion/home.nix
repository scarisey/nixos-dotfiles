{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.devtools.enable = true;
  scarisey.gnome.enable = true;
  scarisey.gui.enable = true;
  scarisey.autoUpdate = {
    enable = true;
    dates = "Fri *-*-* 04:30:00";
    flake = "github:scarisey/nixos-dotfiles";
  };
}
