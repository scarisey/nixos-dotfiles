{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["wireguard"];
  boot.extraModulePackages =
    lib.optional (lib.versionOlder config.boot.kernelPackages.kernel.version "5.6")
    config.boot.kernelPackages.wireguard;
  boot.supportedFilesystems = ["btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4db44b73-bd42-4190-b167-7327f830359f";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EA5D-2230";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/data/disk1" = {
    device = "/dev/disk/by-uuid/e25681a2-916c-4761-a0fe-cb83e97fcf00";
    fsType = "ext4";
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
