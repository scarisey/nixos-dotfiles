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
        ref = "hyperion/prod";
      };
      testSpec = {
        ref = "hyperion/test";
      };
    };
    environmentFile = config.sops.secrets."hyperion/nix_config_pullix".path;
    verbose_logs = false;
    otelHttpEndpoint = "http://localhost:4318/v1/metrics";
    homeManager = {
      package = inputs.home-manager.packages.x86_64-linux.home-manager;
      username = "${config.home.username}";
      group = "users";
    };
  };

  sops.secrets = {
    "hyperion/nix_config_pullix" = {
      path = "${config.home.homeDirectory}/.config/pullix/nix_config_pullix";
      mode = "0400";
    };
    "hyperion/wake-titan" = {
      path = "${config.home.homeDirectory}/.local/bin/wake-titan";
      mode = "0550";
    };
  };
}
