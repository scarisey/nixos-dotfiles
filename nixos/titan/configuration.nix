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
  networking.hostName = "titan";
  services.xserver.videoDrivers = ["nvidia"];
  scarisey.network.enable = true;
  scarisey.network.bridges.enable = true;
  scarisey.qemu.enable = true;
  scarisey.gnome.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  xdg.portal.enable = true;
  services.plex = {
    enable = false;
    openFirewall = true;
  };
  services.flatpak.enable = true;
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
}
