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

  users.users.sylvain = {
    #password cannot be used outside of localhost
    hashedPassword = "$y$j9T$w0oei39SORL3A.qHt6WPj/$7z9WQnfELn6hA1Rbw0nAyC2vXQRh5XP3PijxEP7UVX3";
  };
}
