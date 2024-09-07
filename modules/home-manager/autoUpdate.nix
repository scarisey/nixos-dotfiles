{ pkgs
, lib
, config
, inputs
, ...
}:
with lib; let
  # Shorter name to access final settings a
  # user of devtools.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.scarisey.autoUpdate;
in
{
  options.scarisey.autoUpdate = {
    enable = mkEnableOption "Collection of development tools";
    dates = mkOption {
      type = types.str;
      default = "Fri *-*-* 04:30:00";
      example = "Fri *-*-* 04:30:00";
    };
    flake = mkOption {
      type = types.str;
      example = "github:kloenk/nix";
      description = lib.mdDoc ''
        The Flake URI of the NixOS configuration to build.
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.user = {
      timers.home-manager-auto-upgrade = {
        Unit.Description = "Home Manager upgrade timer";

        Install.WantedBy = [ "timers.target" ];

        Timer = {
          OnCalendar = cfg.dates;
          Unit = "home-manager-auto-upgrade.service";
          Persistent = true;
        };
      };

      services.home-manager-auto-upgrade = {
        Unit.Description = "Home Manager upgrade";

        Service.ExecStart =
          toString
            (pkgs.writeShellScript "home-manager-auto-upgrade" ''
              echo "Upgrade Home Manager"
              ${inputs.home-manager.packages.x86_64-linux.home-manager}/bin/home-manager switch --flake ${cfg.flake}
            '');
      };
    };
  };
}
