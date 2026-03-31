{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.restic;
  resticHdd1 = pkgs.writeShellScriptBin "restic-hdd-1" ''
    export RESTIC_REPOSITORY="/backup/hdd1"
    export RESTIC_PASSWORD_FILE="${config.sops.secrets."restic/hdd-backup-1/repositoryPwd".path}"
    ${pkgs.restic}/bin/restic "$@"
  '';
  mountProton = pkgs.writeShellScriptBin "mount-proton" ''
    if [ "$#" -ne 2 ];then
      echo "mount-proton [2fa code] [mount point]"
    fi
    ${pkgs.rclone}/bin/rclone lsd proton: --protondrive-2fa=$1
    ${pkgs.rclone}/bin/rclone mount proton: $2
  '';
  resticProton = pkgs.writeShellScriptBin "restic-proton" ''
    export RESTIC_REPOSITORY="${config.home.homeDirectory}/backupsRestic/"
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
    all = mkEnableOption "All commands";
    hddBackup1 = mkEnableOption "Command for hdd backup 1";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        restic
      ]
      ++ optionals cfg.hddBackup1 [
        resticHdd1
      ]
      ++ optionals cfg.all [
        resticCronos
        resticProton
        mountProton
      ];

    sops.secrets."restic/hdd-backup-1/repositoryPwd" = mkIf (cfg.all || cfg.hddBackup1) {};
    sops.secrets."restic/protonDrive" = mkIf cfg.all {};
    sops.secrets."restic/cronos-backups/repositoryPwd" = mkIf cfg.all {};
    sops.secrets."restic/cronos-backups/backblaze/envFile" = mkIf cfg.all {};
  };
}
