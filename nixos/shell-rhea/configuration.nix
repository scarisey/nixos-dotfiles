{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = [
    ./hardware.nix
    ../common.nix
  ];
  networking.hostName = "shell-rhea";
  scarisey.network.enable = true;

  programs.zsh = {
    enableCompletion = true;
    enableBashCompletion = true;
  };

}
