{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ../../common.nix
  ];

  scarisey.myshell.enable = true;
  scarisey.devtools.enable = true;
  scarisey.devtools.rust = true;
  scarisey.restic = {
    enable = true;
    all = false;
    hddBackup1 = true;
  };

  services.pullix = {
    enable = true;
    hostname = "hyperion";
    pollIntervalSecs = 60;
    flakeRepo = {
      type = "GitHub";
      repo = "scarisey/nixos-dotfiles";
      prodSpec = {
        ref = "feat/hmPullix";
      };
      testSpec = {
        ref = "feat/hmPullix";
      };
    };
    environmentFile = config.sops.secrets."hyperion/nix_config_pullix".path;
    verbose_logs = true;
    otelHttpEndpoint = "http://localhost:4318/v1/metrics";
  };

  sops.secrets."hyperion/wake-titan" = {
    path = "${config.home.homeDirectory}/.local/bin/wake-titan";
    mode = "0550";
  };
  sops.secrets."hyperion/nix_config_pullix" = {
    path = "${config.home.homeDirectory}/.config/pullix/nix_config_pullix";
    mode = "0400";
  };
}
