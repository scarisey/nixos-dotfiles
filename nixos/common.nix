{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  overlays,
  ...
}: {
  imports = builtins.attrValues outputs.nixosModules ++ [inputs.sops-nix.nixosModules.sops];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = overlays;
  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = ["root" "sylvain"];
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
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd" "kvm"];
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    cachix
  ];
  programs.zsh.enable = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 2";
    flake = "/home/sylvain/git/github.com/scarisey/nixos-dotfiles";
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "23.05";
}
