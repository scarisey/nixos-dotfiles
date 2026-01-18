{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
    ./samba.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "titan";
  services.xserver.videoDrivers = ["nvidia"];

  #automount
  services.udisks2.enable = true;
  services.udev.packages = [pkgs.libgphoto2];
  services.libinput.enable = true;

  scarisey = {
    network.enable = true;
    docker.enable = true;
    qemu.enable = true;
    gnome.enable = true;
  };
  virtualisation.waydroid.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    forceFullCompositionPipeline = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  xdg.portal.enable = true;
  services.flatpak.enable = true;
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.gvfs.enable = true; #for samba
  environment.systemPackages = with pkgs; [
    samba
    libmtp # Base library for MTP
    gphoto2 # Standard tool for Nikon/DSLR cameras
    gphoto2fs #gphotofs <mountdir>
    usbutils # Provides 'lsusb' to check if the camera is seen
  ];
  networking.firewall = {
    allowedTCPPorts = [139 145 5357];
    allowedUDPPorts = [137 138 3702];
    connectionTrackingModules = ["netbios_sn"];
  };
}
