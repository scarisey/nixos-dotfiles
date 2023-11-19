{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = (builtins.attrValues outputs.nixosModules) ++ [
    inputs.nixos-generators.nixosModules.all-formats
  ];
  nixpkgs = {
    overlays = (builtins.attrValues outputs.overlays) ++ [
      inputs.nix-alien.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };
  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
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
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMWBJqOjJ7saqLyiUyE9Oe+rlDB7MoG7LjfAPiTZCrtrc9d6zb50oaXh7BsRpBy9lvyGYjo9WiB16Nntu+Dbwjk="
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBH1fhxnaaI20uWHwBw0o+CgMQwJ2WvBYMXm2616VKCGshrKN6a+ZLXVLA0Lh6W9k+7EnsBnq514FpnAgWcVpeuk="
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEqQhAeQfRzyxx4EQLwVXRfYZ0q73yaubGKOi/wJ2vNY5s1SwjNaI9uzYL9XJ8hJfy+3RUQ+RaSNFWGkfpBNMCs="
    ];
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
  ];
  programs.zsh.enable = true;
  services.openssh = lib.mkDefault {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "23.05";
}
