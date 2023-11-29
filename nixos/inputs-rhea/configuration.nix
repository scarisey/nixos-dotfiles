{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = [
    ./hardware.nix
    ../common.nix
  ];
  networking.hostName = "ipnuts-rhea";
  scarisey.network.enable = true;

  services.transmission = { 
    enable = true; #Enable transmission daemon
    openRPCPort = true; #Open firewall for RPC
    openPeerPorts = true;
    settings = { #Override default settings
      peer-port = 51413;
      rpc-bind-address = "0.0.0.0"; #Bind to own IP
      rpc-whitelist = "127.0.0.1"; #Whitelist your remote machine (10.0.0.1 in this example)
    };
  };

  programs.zsh = {
    enableCompletion = true;
    enableBashCompletion = true;
  };

}
