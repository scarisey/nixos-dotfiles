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
  scarisey.devtools.zed = true;
  scarisey.restic = {
    enable = true;
    all = true;
  };

  home.packages = with pkgs; [
    darktable
    filter-nef-by-rating
  ];
}
