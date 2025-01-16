{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  networking.hostName = "lscarisey";
  scarisey.network.enable = true;
  scarisey.qemu.enable = true;
  scarisey.gnome.enable = true;
  virtualisation.waydroid.enable = true;
  services.ollama.enable = true;
  services.tlp.enable = true; #battery care
  services.power-profiles-daemon.enable = false; #since tlp is enabled
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
    ];
  };
  xdg.portal.enable = true;
  services.flatpak.enable = true;
  services.printing.enable = true;
  hardware.pulseaudio.enable = false;
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
    smartmontools
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
