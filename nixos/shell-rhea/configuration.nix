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
    hashedPassword = "$y$j9T$FFPOi.DlX8Hs7CL586FWQ0$4vBkcRlV3F93EkzzKMjqB/su57nAdqTwceyKUqmCn66";
  };

  inherit (../../home-manager/sylvain/shell-rhea/home.nix {});

}
