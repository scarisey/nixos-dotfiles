{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = builtins.attrValues outputs.nixosModules ++ [ inputs.sops-nix.nixosModules.sops ];
  nixpkgs = {
    overlays =
      (builtins.attrValues outputs.overlays)
      ++ [
        inputs.nix-alien.overlays.default
      ];
    config = {
      allowUnfree = true;
    };
  };
  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = ["root" "sylvain"];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Paris";
  };
  i18n = {
    defaultLocale = "fr_FR.UTF-8";
  };
  console.keyMap = "fr";
  services.journald = {
    extraConfig = ''
      SystemMaxUse=512MB
      RuntimeMaxUse=512MB
    '';
  };
  users.users.sylvain = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "sylvain";
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd"];
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    cachix
  ];
  programs.zsh.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "23.05";
}
