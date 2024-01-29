{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = [
    ../common.nix
    inputs.nixos-wsl.nixosModules.wsl
  ];

  networking.hostName = "titan-wsl";

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    defaultUser = "sylvain";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = false;
  };

  environment.systemPackages = [
    pkgs.win32yank
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
}
