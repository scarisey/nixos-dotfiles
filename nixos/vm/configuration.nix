{ pkgs,inputs,config, ... }: {
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
      ref = "feat/vmTest";
    };
    flakeProdRepo = {
      type = "GitHub";
      repo = "scarisey/nixos-dotfiles";
      ref = "feat/vmProd";
    };
    environmentFile = config.sops.secrets."vm/nix_config_env".path;
  };

  environment.systemPackages = with pkgs; [
    inputs.pullix.packages."x86_64-linux".pullix
  ];

  sops = {
    defaultSopsFile = "${inputs.private-vault}/secrets.yaml";
    age.keyFile = "/home/sylvain/.config/sops/age/keys.txt";
    secrets."vm/nix_config_env" = {};
  };
}
