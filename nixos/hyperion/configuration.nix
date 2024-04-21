{ lib
, config
, pkgs
, inputs
, outputs
, ...
}:
let
  adminpassFile =
    pkgs.writeText "adminpassFile"
      ''
        IShouldBeChanged
      '';
in
{
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
  services.nextcloud = {
    enable = true;
    hostName = "localhost";
    config.adminpassFile = "${adminpassFile}";
    package = pkgs.nextcloud28;
  };
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
