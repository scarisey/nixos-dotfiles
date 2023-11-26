{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = [
    ./hardware.nix
    ../common.nix
    inputs.home-manager.nixosModules.home-manager
  ];
  networking.hostName = "shell-rhea";
  scarisey.network.enable = true;

  programs.zsh = {
    enableCompletion = true;
    enableBashCompletion = true;
  };

  inherit (../../home-manager/sylvain/shell-rhea/home.nix {});

}
