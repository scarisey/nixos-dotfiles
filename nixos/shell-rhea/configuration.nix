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

  users.users.sylvain = {
    #password cannot be used outside of localhost
    hashedPassword = "$y$j9T$v262u5DLusg/VSY.23LS61$0w0TSNEPngUtNt9s4fdryVqVDHkKpF8rREwBobotHE1";
  };

  inherit (home-manager {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.sylvain = (import ../../home-manager/sylvain/shell-rhea/home.nix {});
  });

}
