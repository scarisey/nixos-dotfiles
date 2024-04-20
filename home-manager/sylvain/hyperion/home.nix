{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.devtools.enable = true;

  home.packages = with pkgs; [
    unstable.firefox
    unstable.vlc
    xclip
    pavucontrol
  ];
}
