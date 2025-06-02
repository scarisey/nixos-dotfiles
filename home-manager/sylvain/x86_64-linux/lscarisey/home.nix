{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  targets.genericLinux.enable = true;

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.gui.nixgl.enable = true;
  scarisey.gui.obs = true;
  scarisey.devtools = {
    enable = true;
    all = true;
    vscode = true;
    intellij = true;
  };
  scarisey.cloud.all = true;
  scarisey.cloud.enable = true;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    keepassxc
    msgconvert
    glab-tools
    pritunl-client
  ];

  home.file.".local/bin/firewall.sh" = {
    source = ./firewall.sh;
    executable = true;
  };
}
