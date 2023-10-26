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
    k9s = mkEnableOption "K9S";
    kubectl = mkEnableOption "kubectl";
    helm = mkEnableOption "helm";
    azure = mkEnableOption "az cli";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;  pkgIf cfg.k9s unstable.k9s ++ pkgIf cfg.kubectl unstable.kubectl
      ++ pkgIf cfg.kubectl unstable.kubelogin
      ++ pkgIf cfg.helm unstable.kubernetes-helm ++ pkgIf cfg.azure azure-cli;
  };

}
