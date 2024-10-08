{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../../common.nix
  ];

  targets.genericLinux.enable = true;

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.gui.obs = true;
  scarisey.devtools = {
    enable = true;
    all = true;
    intellij = true;
  };
  scarisey.cloud.all = true;
  scarisey.cloud.enable = true;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    keepassxc
    msgconvert
    vscode
  ];

  stylix.image = pkgs.fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/image12/Minimalist-forest-lake-reflection-with-tall-trees-and-a-tranquil-glass-like-surface-set-in-a-peaceful-woodland.jpg";
    hash = "sha256-6jSYP6zArfOx9psvGTXeljHlZ8EyDaHMJkb2OHGTYEo=";
  };
}
