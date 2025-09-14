{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  overlays,
  ...
}: {
  imports =
    builtins.attrValues outputs.nixosModules
    ++ [
      inputs.sops-nix.nixosModules.sops
      inputs.homelab-nix.nixosModules.homelab
      inputs.private-modules.nixosModules.privateModules
    ];
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
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCGMOV7eUZHjaQAX3DasvWYR8I1lFe5mp3hjTq+Cc2okkfrTqW1mA5LLtkwvjpUgWixA3Y0OM9/+XTbYF80c1J8= lscarisey"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfzo6os2jVd/4Q0BVk9sbn3GqQeyCddzCd4ZkgDmBLY galaxyS25"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMWBJqOjJ7saqLyiUyE9Oe+rlDB7MoG7LjfAPiTZCrtrc9d6zb50oaXh7BsRpBy9lvyGYjo9WiB16Nntu+Dbwjk= titan"
    ];
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    cachix
  ];
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=30s
  '';
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
