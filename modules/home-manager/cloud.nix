{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.cloud;
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
    home.packages = with pkgs;  [
      (mkIf (cfg.all || cfg.k9s) unstable.k9s )
        (mkIf (cfg.all || cfg.kubectl) unstable.kubectl)
        (mkIf (cfg.all || cfg.kubectl) unstable.kubelogin)
        (mkIf (cfg.all || cfg.helm) unstable.kubernetes-helm )
        (mkIf (cfg.all || cfg.azure) azure-cli)
    ];
  };

}
