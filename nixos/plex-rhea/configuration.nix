{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = [
    ./hardware.nix
    ../common.nix
  ];
  networking.hostName = "plex-rhea";
  scarisey.network.enable = true;

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  programs.zsh = {
    enableCompletion = true;
    enableBashCompletion = true;
  };

}
