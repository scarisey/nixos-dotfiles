{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./audiobookshelf.nix
    ./hardware.nix
    ../common.nix
    ./docker.nix
    ./frigate.nix
    ./homelab.nix
    ./immich.nix
    ./microbin.nix
    ./nfs.nix
    ./samba.nix
    ./vpnServer.nix
    inputs.pullix.nixosModules.default
  ];

  nixpkgs.config.allowBroken = true; #FIXME for immich to build

  scarisey.privateModules.enable = true;

  services.pullix = {
    enable = true;
    hostname = "hyperion";
    pollIntervalSecs = 60;
    flakeRepo = {
      type = "GitHub";
      repo = "scarisey/nixos-dotfiles";
      prodSpec = {
        ref = "hyperion/prod";
      };
      testSpec = {
        ref = "hyperion/test";
      };
    };
    environmentFile = config.sops.secrets."hyperion/nix_config_pullix".path;
    verbose_logs = false;
    otelHttpEndpoint = "http://localhost:4318/v1/metrics";
  };

  environment.systemPackages = with pkgs; [
    smartmontools
    wol
  ];
  services.fail2ban.enable = true;

  services.smartd = {
    enable = true;
    devices = [
      {
        device = "/dev/sda";
      }
    ];
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  programs.nh.clean.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "hyperion";
  networking.firewall = {
    connectionTrackingModules = ["netbios_sn"];
  };
  sops = {
    defaultSopsFile = "${inputs.private-vault}/secrets.yaml";
    age.keyFile = "/home/sylvain/.config/sops/age/keys.txt";
    secrets."hyperion/samba/freebox" = {};
    secrets."hyperion/grafana/init_passwd" = {
      mode = "0440";
      group = "grafana";
    };
    secrets."hyperion/grafana/init_secret" = {
      mode = "0440";
      group = "grafana";
    };
    secrets."hyperion/postgresql/grafana_role_postscript" = {
      mode = "0440";
      group = "postgres";
    };
    secrets."hyperion/postgresql/blocky_grants" = {
      mode = "0440";
      group = "postgres";
    };
    secrets."hyperion/postgresql/blocky_password" = {
      mode = "0440";
    };
    secrets."hyperion/microbin/passwordFile" = {
      mode = "0440";
      group = "microbin-sec";
    };
    secrets."hyperion/wireguard/server/privateKey" = {
      mode = "0440";
    };
    secrets."restic/cronos-backups/repositoryPwd" = {
      mode = "0400";
      owner = "restic";
    };
    secrets."restic/cronos-backups/backblaze/envFile" = {
      mode = "0400";
      owner = "restic";
    };
    secrets."hyperion/ionos/environmentFile" = {
      mode = "0400";
      owner = "acme";
    };
    secrets."hyperion/maxmind/license" = {
      mode = "0440";
    };
    secrets."hyperion/nix_config_pullix" = {
      mode = "0440";
    };
  };
}
