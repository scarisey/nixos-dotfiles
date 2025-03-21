{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
    ./samba.nix
    ./network.nix
    ./proxy.nix
  ];

  environment.systemPackages = with pkgs; [
    qbittorrent
    smartmontools
  ];

  scarisey.qemu.enable = true;
  scarisey.gnome.enable = true;
  scarisey.gnome.wayland = false;
  services.plex = {
    enable = true;
    openFirewall = true;
  };
  users.users.plex.extraGroups = ["users"];
  services.cockpit = {
    enable = true;
    openFirewall = true;
    port = 9090;
  };

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
  xdg.portal.enable = true;
  services.printing.enable = true;
  hardware.pulseaudio.enable = false;
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
    flags = [
      "--accept-flake-config"
    ];
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "hyperion";
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age.keyFile = "/home/sylvain/.config/sops/age/keys.txt";
    secrets."hyperion/vpn" = {};
    secrets."hyperion/samba/freebox" = {};
  };
}
