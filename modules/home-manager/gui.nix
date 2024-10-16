{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.gui;
in {
  options.scarisey.gui = {
    enable = mkEnableOption "Common GUI tools";
    obs = mkEnableOption "OBS Studio";
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      TERMINAL = "kitty";
    };

    programs.firefox.enable = true;

    home.packages = with pkgs; [
      vlc
      amberol

      kitty
      alacritty
      neovide

      xclip
      pavucontrol
      flameshot

      scrcpy

      (mkIf cfg.obs obs-studio)
    ];

    home.file.".alacritty.toml" = {
      source = ./alacritty/alacritty.toml;
    };

    programs.kitty = lib.mkForce {
      enable = true;
      settings = {
        scrollback_pager = "nvimpager -p -- -c 'lua nvimpager.maps=false'";
        enable_audio_bell = false;
        hide_window_decorations = true;
        tab_bar_style = "powerline";
        tab_powerline_styled = "angled";
        # background_opacity = "0.95";
        # dynamic_background_opacity = true;
        confirm_os_window_close = 0;

        font_size = 11;
        font_family = "MesloLGS Nerd Font Mono";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
      };
      keybindings = {
        "ctrl+left" = "neighboring_window left";
        "shift+left" = "move_window right";
        "ctrl+down" = "neighboring_window down";
        "shift+down" = "move_window up";
        "ctrl+right" = "neighboring_window right";
        "shift+right" = "move_window left";
        "ctrl+up" = "neighboring_window up";
        "shift+up" = "move_window down";
      };
    };

    stylix = {
      enable = true;
      polarity = "dark";
      fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };

        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "Ubuntu Regular";
        };

        monospace = {
          package = pkgs.dejavu_fonts;
          name = "UbuntuMono Nerd Font Regular";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
      targets.kitty.enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/shadesmear-dark.yaml";
    };
  };
}
