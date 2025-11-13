{
  config,
  lib,
  ...
}: let
  privateModulesGroup = config.scarisey.privateModules.group;
in {
  services.jellyfin.enable = true;
  users.users.jellyfin.extraGroups = [privateModulesGroup];
  users.users.sylvain.extraGroups = lib.mkAfter [privateModulesGroup];
  scarisey.homelab = {
    enable = lib.mkForce true;
    settings = {
      email = "sylvain@carisey.dev";
      lanPort = 443;
      wanPort = 8443;
      ipv4 = "192.168.1.79";
      ipv6 = "fe80::291b:a25b:4e6d:5a84";
      domains = let
        rootDomain = "carisey.dev";
        internalDomain = "internal.${rootDomain}";
      in {
        root = rootDomain;
        internal = internalDomain;
        wildcardInternal = "*.${internalDomain}";
        grafana = "grafana-hyperion.${rootDomain}";
        public = {
          jellyfin = {
            domain = "jellyfin.${rootDomain}";
            proxyPass = "http://localhost:8096";
          };
          microbin = {
            domain = "microbin.${rootDomain}";
            proxyPass = "http://127.0.0.1:8080$request_uri";
          };
          immich = {
            domain = "immich.${rootDomain}";
            proxyPass = "http://127.0.0.1:${builtins.toString config.services.immich.port}";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 8196M;
            '';
          };
          audiobookshelf = {
            domain = "audiobookshelf.${rootDomain}";
            proxyPass = "http://${config.services.audiobookshelf.host}:${builtins.toString config.services.audiobookshelf.port}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_redirect http:// $scheme://;
            '';
          };
        };
        lan = { };
      };
      grafana = {
        security = {
          admin_user = "admin";
          admin_password = "$__file{/run/secrets/hyperion/grafana/init_passwd}"; #only for first setup
          secret_key = "$__file{/run/secrets/hyperion/grafana/init_secret}"; #only for first setup
        };
      };
      postgresql.postscripts = {
        grafana = config.sops.secrets."hyperion/postgresql/grafana_role_postscript".path;
        blocky = config.sops.secrets."hyperion/postgresql/blocky_grants".path;
      };
      blocky = {
        clientLookup.clients.agmob = [
          "192.168.1.11"
          "fe80::54d2:b5ff:fef1:61e5"
        ];
        blocking = {
          blockType = "zeroIP";
          denylists = {
            ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
            fakenews = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"];
          };
          clientGroupsBlock = {
            default = ["ads" "fakenews"];
            agmob = ["fakenews"];
          };
        };
        environmentFile = "/run/secrets/hyperion/postgresql/blocky_password";
      };
    };
    backups = {
      enable = true;
      groups = [config.services.jellyfin.group];
      repository = {
        name = "cronos-backups";
        url = "s3:https://s3.eu-central-003.backblazeb2.com/cronos-backups";
        environmentFile = config.sops.secrets."restic/cronos-backups/backblaze/envFile".path;
        passwordFile = config.sops.secrets."restic/cronos-backups/repositoryPwd".path;
        locations = [
          "${config.services.immich.mediaLocation}"
          "${config.services.jellyfin.dataDir}"
          "/var/lib/audiobookshelf/metadata/backups"
          "/data/disk1/MusicImport/"
          "/data/disk1/Musique/"
          "${config.services.grafana.dataDir}"
          "${config.services.postgresqlBackup.location}"
        ];
      };
    };
    textfileCollector = {
      publicFlakeUrl = "https://github.com/scarisey/nixos-dotfiles.git";
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "sylvain";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["sylvain"];
  };

  services.postgresqlBackup = {
    enable=true;
    backupAll=true;
    startAt="*-*-* 23:00:00";
  };
}
