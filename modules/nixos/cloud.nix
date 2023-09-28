{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.cloud;
  pkgIf = pred: package: optionals (cfg.all || pred) [ package ];
in
{
  options.scarisey.cloud = {
    enable = mkEnableOption "My cloud config";
    all = mkEnableOption "All cloud software installed";
    docker = mkEnableOption "Docker";
    k9s = mkEnableOption "K9S";
    kubectl = mkEnableOption "kubectl";
    helm = mkEnableOption "helm";
    azure = mkEnableOption "az cli";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = cfg.all || cfg.docker;
    environment.systemPackages = with pkgs;  pkgIf cfg.k9s k9s ++ pkgIf cfg.kubectl kubectl
      ++ pkgIf cfg.helm kubernetes-helm ++ pkgIf cfg.azure aazure-cli;
  };

}
