{pkgs, ...}: {
  imports = [
    ../../common.nix
  ];

  targets.genericLinux.enable = true;

  scarisey.myshell.enable = true;
  scarisey.gui.enable = true;
  scarisey.gui.obs = true;
  scarisey.gui.stylix = true;
  scarisey.devtools = {
    enable = true;
    all = true;
  };
  scarisey.cloud.all = true;
  scarisey.cloud.enable = true;

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    keepassxc
    msgconvert
    glab-tools
  ];

  stylix = {
    autoEnable = false;
    targets = {
      bat.enable = true;
      btop.enable = true;
      firefox.enable = true;
      fzf.enable = true;
      k9s.enable = true;
      kitty.enable = true;
      vim.enable = true;
      yazi.enable = true;
    };
  };
}
