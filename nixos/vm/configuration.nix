{ pkgs,inputs, ... }: {
  imports = [
    ./hardware.nix
    ../common.nix
    inputs.pullix.nixosModules.default
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


  services.pullix = {
    enable = true;
    hostname = "vm";
    pollIntervalSecs = 10;
    flakeTestRepo = {
      type = "GitHub";
      repo = "scarisey/nixos-dotfiles";
      ref = "feat/vm";
    };
    flakeProdRepo = {
      type = "GitHub";
      repo = "scarisey/nixos-dotfiles";
      ref = "feat/vmProd";
    };
  };

  environment.systemPackages = with pkgs; [
    inputs.pullix.packages."x86_64-linux".pullix
  ];
}
