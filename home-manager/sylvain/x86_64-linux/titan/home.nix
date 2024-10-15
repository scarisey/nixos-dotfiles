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
    url = "https://bitbucket.org/SCarSly/wallpapers/raw/c15754dfdbb687804f38e2e39d6bd86734de2269/pexels-eberhardgross-730981.jpg";
    hash = "sha256-HH+RVs8g+lF+E5XHXDXOR03vi1c8uivQ517uvbrQ7dA=";
# nix-hash --type sha256 --to-sri $(nix-prefetch-url [URL])
  };
}
