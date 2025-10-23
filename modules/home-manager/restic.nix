{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.restic;
  resticProton = pkgs.writeShellScriptBin "restic-proton" ''
    export RESTIC_REPOSITORY="/home/sylvain/backupsRestic/"
    export RESTIC_PASSWORD_FILE="${config.sops.secrets."restic/protonDrive".path}"
    ${pkgs.restic}/bin/restic "$@"
  '';
  resticCronos = pkgs.writeShellScriptBin "restic-cronos" ''
    export RESTIC_REPOSITORY="s3:https://s3.eu-central-003.backblazeb2.com/cronos-backups"
    export RESTIC_PASSWORD_FILE="${config.sops.secrets."restic/cronos-backups/repositoryPwd".path}"
    set -a
    source ${config.sops.secrets."restic/cronos-backups/backblaze/envFile".path}
    set +a
    ${pkgs.restic}/bin/restic "$@"
  '';
in {
  options.scarisey.restic = {
    enable = mkEnableOption "Restic settings.";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      restic
      resticCronos
      resticProton
    ];

    sops.secrets."restic/protonDrive" = {};
    sops.secrets."restic/cronos-backups/repositoryPwd" = {};
    sops.secrets."restic/cronos-backups/backblaze/envFile" = {};
  };
}
