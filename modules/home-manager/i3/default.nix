{ pkgs, config, lib, ... }:
with lib;
let
  # Shorter name to access final settings a 
  # user of devtools.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.scarisey.i3; in
{
  options.scarisey.i3 = {
    enable = mkEnableOption "i3 home configuration";
    browserPath = mkOption {
      type = types.path;
      default = "${pkgs.firefox}/bin/firefox";
      defaultText = literalExpression "\${pkgs.firefox} + /bin/firefox";
      example = literalExpression ''
        $${pkgs.firefox} + /bin/firefox
      '';
      description = mdDoc ''
        Specify which package to use for the browser triggered in i3.
      '';
    };
    fileManagerPath = mkOption {
      type = types.path;
      default = "${pkgs.xfce.thunar}/bin/thunar";
      defaultText = literalExpression "\${pkgs.xfce.thunar}/bin/thunar";
      example = literalExpression ''
        $${pkgs.xfce.thunar}/bin/thunar
      '';
      description = mdDoc ''
        Specify which package to use for the file manager triggered in i3.
      '';
    };
    terminalPath = mkOption {
      type = types.path;
      default = "${pkgs.alacritty}/bin/alacritty";
      defaultText = literalExpression "\${pkgs.alacritty}/bin/alacritty";
      example = literalExpression ''
        $${pkgs.alacritty}/bin/alacritty
      '';
      description = mdDoc ''
        Specify which package to use for the terminal triggered in i3.
      '';
    };
  };

  config = mkIf cfg.enable {

    home.file = {
      ".config/i3/config".source = ./config;
      ".config/picom.conf".source = ./picom.conf;
      ".config/i3/i3blocks.conf".source = ./i3blocks.conf;
      ".screenlayouts/monitor.sh".source = ./scripts/monitor.sh;
      ".config/i3/scripts" = {
        source = ./scripts;
        # copy the scripts directory recursively
        recursive = true;
        executable = true; # make all scripts executable
      };

      # rofi is a application launcher and dmenu replacement
      ".config/rofi" = {
        source = ./rofi-conf;
        # copy the scripts directory recursively
        recursive = true;
      };

    };

    # allow fontconfig to discover fonts and configurations installed through home.packages
    fonts.fontconfig.enable = true;

    systemd.user.sessionVariables = {
      "I3_BROWSER" = "${cfg.browserPath}";
      "I3_FILE_MANAGER" = "${cfg.fileManagerPath}";
      "I3_TERMINAL" = "${cfg.terminalPath}";
      "LIBVA_DRIVER_NAME" = "nvidia";
      "GBM_BACKEND" = "nvidia-drm";
      "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    };

  };
}
