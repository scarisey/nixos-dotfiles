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
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
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
  ];
  networking.firewall = {
    allowedTCPPorts = [139 145 5357];
    allowedUDPPorts = [137 138 3702];
    connectionTrackingModules = ["netbios_sn"];
  };
}
