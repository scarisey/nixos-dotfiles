{ lib
, config
, pkgs
, inputs
, outputs
, ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  scarisey.network.enable = true;
  scarisey.qemu.enable = true;
  scarisey.gnome.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  scarisey.vpn = {
    enable = true;
    confPath = "/var/lib/protonvpn/hyperion.conf";
  };
  #SAMBA
  services = {
    gvfs.enable = true;
    avahi = {
      publish.enable = true;
      publish.userServices = true;
      enable = true;
      openFirewall = true;
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    samba = {
      #For a user called my_userto be authenticated on the samba server, you must add their password using
      #smbpasswd -a someUser
      package = pkgs.samba4Full;
      enable = true;
      openFirewall = true;
      shares.public = {
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        path = "/data/Public";
        comment = "Hello World!";
        public = "yes";
      };
      shares.private = {
        browseable = "yes";
        writeable = "yes";
        path = "home/sylvain/private";
      };
      extraConfig = ''
        server smb encrypt = desired
        # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
        server min protocol = SMB3_00
        security = user
        map to guest = bad user
        guest account = nobody
      '';
    };
  };
  environment.systemPackages = with pkgs; [
    qbittorrent
  ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
  };
  xdg.portal.enable = true;
  services.printing.enable = true;
  sound.enable = true;
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
}
