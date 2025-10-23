{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.kde;
in {
  options.scarisey.kde = {
    enable = mkEnableOption "KDE settings";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [libsForQt5.ksshaskpass libsForQt5.kwallet-pam materia-kde-theme papirus-icon-theme];

    home.file.".config/plasma-workspace/env/ssh-agent-startup.sh" = {
      source = ./kde/ssh-agent-startup.sh;
    };
    home.file.".config/plasma-workspace/shutdown/ssh-agent-shutdown.sh" = {
      source = ./kde/ssh-agent-shutdown.sh;
    };
    home.file.".config/autostart-scripts/kwallet-ssh-add.sh" = {
      source = ./kde/kwallet-ssh-add.sh;
    };
  };
}
