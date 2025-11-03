{
  config,
  lib,
  pkgs,
  ...
}: {
  users.users.restic = {
    isNormalUser = true;
    extraGroups = [ config.scarisey.homelab.group config.services.jellyfin.group ];
  };

  security.wrappers.restic = {
    source = "${pkgs.restic}/bin/restic";
    owner = "restic";
    group = config.scarisey.homelab.group;
    permissions = "u=rwx,g=,o=";
    capabilities = "cap_dac_read_search=+ep";
  };

  services.restic.backups.cronos-backups = {
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/cronos-backups";
    environmentFile = config.sops.secrets."restic/cronos-backups/backblaze/envFile".path;
    passwordFile = config.sops.secrets."restic/cronos-backups/repositoryPwd".path;
    initialize = true;
    user = "restic";
    paths = [
      "${config.services.immich.mediaLocation}"
      "${config.services.jellyfin.dataDir}"
      "/var/lib/audiobookshelf/metadata/backups"
      "/data/disk1/MusicImport/"
      "/data/disk1/Musique/"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-last 3"
    ];
    package = pkgs.writeShellScriptBin "restic-wrapper" ''
      exec /run/wrappers/bin/restic "$@"
    '';
  };
}
