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
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
        "nixpkgs"
        "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

}
