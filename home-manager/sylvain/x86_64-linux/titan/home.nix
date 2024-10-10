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
  scarisey.gnome.enable = true;

  home.packages = with pkgs; [
    nix-alien
    protonvpn-gui
    picard
  ];
  stylix.image = pkgs.fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/image10/Fall-Desktop-Wallpaper-2K-with-a-hiking-trail-through-a-forest-in-autumn-leaves-crunching-underfoot.jpg";
    hash = "sha256-G60ahkOYLwhnFoxsQYdiuhaCNfZ8HF8Sx8P66ptFGrQ=";
  };
}
