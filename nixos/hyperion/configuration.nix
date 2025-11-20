{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./audiobookshelf.nix
    ./hardware.nix
    ../common.nix
    ./docker.nix
    ./homelab.nix
    ./immich.nix
    ./microbin.nix
    ./paperless.nix
    ./samba.nix
    ./vpnServer.nix
  ];

  nixpkgs.config.allowBroken = true; #FIXME for immich to build

  scarisey.privateModules.enable = true;

  environment.systemPackages = with pkgs; [
    smartmontools
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
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [vaapiIntel];
  };
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
  system.autoUpgrade = {
    enable = true;
    flake = "github:scarisey/nixos-dotfiles";
    dates = "Fri *-*-* 04:00:00";
    # upgrade = false; # coming nixos 25.11
    flags = [
      "--accept-flake-config"
      "--no-write-lock-file" # until nixos 25.11
    ];
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
    secrets."hyperion/paperless/passwordFile" = {
      mode = "0440";
      owner = config.services.paperless.user;
    };
    secrets."hyperion/paperless/environmentFile" = {
      mode = "0440";
      owner = config.services.paperless.user;
    };
    secrets."restic/cronos-backups/repositoryPwd" = {
      mode = "0400";
      owner = "restic";
    };
    secrets."restic/cronos-backups/backblaze/envFile" = {
      mode = "0400";
      owner = "restic";
    };
  };
}
