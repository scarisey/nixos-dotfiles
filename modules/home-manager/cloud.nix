{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.cloud;
in {
  options.scarisey.cloud = {
    enable = mkEnableOption "My cloud config";
    all = mkEnableOption "All cloud software installed";
    k9s = mkEnableOption "K9S";
    kubectl = mkEnableOption "kubectl";
    helm = mkEnableOption "helm";
    azure = mkEnableOption "az cli";
    kcat = mkEnableOption "kafka cat";
    dive = mkEnableOption "Deep dive into your docker image";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (mkIf (cfg.all || cfg.k9s) k9s)
      (mkIf (cfg.all || cfg.kubectl) kubectl)
      (mkIf (cfg.all || cfg.kubectl) kubelogin)
      (mkIf (cfg.all || cfg.helm) kubernetes-helm)
      (mkIf (cfg.all || cfg.azure) azure-cli)
      (mkIf (cfg.all || cfg.kcat) kcat)
      (mkIf (cfg.all || cfg.dive) dive)
    ];
  };
}
