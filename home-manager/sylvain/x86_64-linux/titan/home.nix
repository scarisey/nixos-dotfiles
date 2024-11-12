{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.gui.obs = true;
  scarisey.devtools.enable = true;
  scarisey.devtools.all = true;
  scarisey.devtools.intellij = true;
  scarisey.devtools.android = true;
  scarisey.gnome.enable = false;
  scarisey.kde.enable = true;

  home.packages = with pkgs; [
    nix-alien
    protonvpn-gui
    picard
  ];
  stylix.image = pkgs.fetchurl {
    url = "https://bitbucket.org/SCarSly/wallpapers/raw/5e25a4ad3232623df88b9fcbbcee1d76429dd919/pexels-francesco-ungaro-1525041.jpg";
    hash = "sha256-gC2WjdoK3lQ2sbP4zoNHdkdZ+E0dR3yiTobBzpV9yzU=";
    # nix-hash --type sha256 --to-sri $(nix-prefetch-url [URL])
  };
}
