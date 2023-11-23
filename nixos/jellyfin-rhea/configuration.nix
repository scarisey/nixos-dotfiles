{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = [
    ./hardware.nix
    ../common.nix
  ];
  networking.hostName = "jellyfin-rhea";
  scarisey.network.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  programs.zsh = {
    enableCompletion = true;
    enableBashCompletion = true;
  };

}
