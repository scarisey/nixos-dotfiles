{...}: {
  users.users.restic.createHome = lib.mkForce false;
  services.postgresqlBackup = {
    enable = config.services.postgresql.enable;
    databases = config.services.postgresql.ensureDatabases;
  };
  services.restic = {
    server = {
      enable = true;
      dataDir = "/var/backups/restic";
      extraFlags = ["--no-auth"];
    };
    backups = let
      passwordFile = "/run/secrets/${config.networking.hostName}/restic/password";
    in {
      appdata-local = {
        timerConfig = {
          OnCalendar = "Mon..Sat *-*-* 05:00:00";
          Persistent = true;
        };
        repository = "rest:http://localhost:8000/appdata-local-${config.networking.hostName}";
        initialize = true;
        inherit passwordFile;
        pruneOpts = [
          "--keep-last 5"
        ];
        exclude = [
        ];
        paths = [
          "/tmp/appdata-local-${config.networking.hostName}.tar"
        ];
        backupPrepareCommand = let
          restic = "${pkgs.restic}/bin/restic -r '${config.services.restic.backups.appdata-local.repository}' -p ${passwordFile}";
        in ''
          ${restic} stats || ${restic} init
          ${pkgs.restic}/bin/restic forget --prune --no-cache --keep-last 5
          ${pkgs.gnutar}/bin/tar -cf /tmp/appdata-local-${config.networking.hostName}.tar ${stateDirs}
          ${restic} unlock
        '';
      };
    };
  };

  sops.secrets."hyperion/restic/password" = {
    mode = "0440";
    group = "restic";
  };
}
