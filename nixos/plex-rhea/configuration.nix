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

  users.users.sylvain = {
    #password cannot be used outside of localhost
    hashedPassword = "$y$j9T$ildrgr/AZztZX8xjaQ2EG0$olCstgEx9yILmo/ds18JO/iOr9GBUZly9b6KIAex9E0";
  };
}
