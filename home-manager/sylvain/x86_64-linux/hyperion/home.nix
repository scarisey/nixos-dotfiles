{
  pkgs,
  lib,
  config,
  ...
}: {
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

  stylix.image = pkgs.fetchurl {
    url = "https://github.com/NixOS/nixos-artwork/blob/ea1384e183f556a94df85c7aa1dcd411f5a69646/wallpapers/nixos-wallpaper-catppuccin-mocha.png?raw=true";
    hash = "sha256-fmKFYw2gYAYFjOv4lr8IkXPtZfE1+88yKQ4vjEcax1s=";
  };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
}
