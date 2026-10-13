{...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    useOSProber = true;
  };
  networking.hostName = "telesto";
  programs.nm-applet.enable = true;
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.lxqt.enable = true;
    xkb = {
      layout = "fr";
      variant = "";
    };
  };

  services.udisks2.enable = true;
  services.libinput.enable = true;

  scarisey = {
    network.enable = true;
  };

  xdg.portal.enable = true;
  security.rtkit.enable = true;
}
