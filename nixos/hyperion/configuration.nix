{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "hyperion";
  scarisey.gnome.enable = true;
  scarisey.network.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  users.users.jellyfin.extraGroups = ["users"];
  #SAMBA
  services = {
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
      #smbpasswd -a someUser
      package = pkgs.samba4Full;
      enable = true;
      openFirewall = true;
      shares.public = {
        path = "/home/sylvain/Public";
        writable = "true";
        comment = "Hello World!";
      };
      extraConfig = ''
        server smb encrypt = required
        # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
        server min protocol = SMB3_00
      '';
    };
  };
  environment.systemPackages = with pkgs; [
    cifs-utils
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
    extraPackages32 = with pkgs.pkgsi686Linux; [vaapiIntel];
  };
  xdg.portal.enable = true;
  services.flatpak.enable = true;
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
}
