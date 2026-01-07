{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "vm";
  networking.networkmanager.enable = true;


  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire.enable = false;
}
