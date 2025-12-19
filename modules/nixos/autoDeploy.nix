{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.scarisey.autoDeploy;

  deployScript = pkgs.writeShellScriptBin "deploy-tags" ''
    set -euo pipefail

    PATH=${makeBinPath [pkgs.git pkgs.nixos-rebuild pkgs.nix pkgs.coreutils pkgs.gnugrep]}
    mkdir -p ${cfg.stateDir}

    # Helper function to get the current commit hash of a remote tag
    get_tag_hash() {
      git ls-remote ${cfg.repoUrl} "refs/tags/$1" | cut -f1
    }

    # 0. Init files if they don't exists
    TEST_HASH=$(get_tag_hash "${cfg.testTag}")
    SWITCH_HASH=$(get_tag_hash "${cfg.switchTag}")

    if [[ ! -f "${cfg.stateDir}/last_test_hash" ]]; then
        echo $TEST_HASH > ${cfg.stateDir}/last_test_hash
    fi
    if [[ ! -f "${cfg.stateDir}/last_switch_hash" ]]; then
        echo $SWITCH_HASH > ${cfg.stateDir}/last_switch_hash
    fi

    # 1. Handle the "Test" Tag
    LAST_TEST_HASH=""
    [ -f ${cfg.stateDir}/last_test_hash ] && LAST_TEST_HASH=$(cat ${cfg.stateDir}/last_test_hash)

    if [ -n "$TEST_HASH" ] && [ "$TEST_HASH" != "$LAST_TEST_HASH" ]; then
      echo "New hash for ${cfg.testTag} detected. Running nixos-rebuild test..."
      nixos-rebuild test --flake "${cfg.flakeBaseUrl}/${cfg.testTag}#${cfg.hostname}"
      if [[ "$?" -eq "0" ]]; then
        echo "$TEST_HASH" > ${cfg.stateDir}/last_test_hash
        echo "Successfully tested $TEST_HASH"
        exit 0
      fi
    fi

    # 2. Handle the "Switch" Tag
    LAST_SWITCH_HASH=""
    [ -f ${cfg.stateDir}/last_switch_hash ] && LAST_SWITCH_HASH=$(cat ${cfg.stateDir}/last_switch_hash)

    if [ -n "$SWITCH_HASH" ] && [ "$SWITCH_HASH" != "$LAST_SWITCH_HASH" ]; then
      echo "New hash for ${cfg.switchTag} detected. Running nixos-rebuild switch..."
      nixos-rebuild switch --flake "${cfg.flakeBaseUrl}/${cfg.switchTag}#${cfg.hostname}"
      if [[ "$?" -eq "0" ]]; then
        echo "$SWITCH_HASH" > ${cfg.stateDir}/last_switch_hash
        # If we switch, it implies the test hash is also effectively "processed"
        echo "$SWITCH_HASH" > ${cfg.stateDir}/last_test_hash
        echo "Successfully switched to $SWITCH_HASH"
        exit 0
      fi
    fi
  '';
in {
  options.scarisey.autoDeploy = {
    enable = mkEnableOption "Dual-tag NixOS Deployer";

    repoUrl = mkOption {
      type = types.str;
      description = "HTTPS URL for ls-remote check.";
    };

    flakeBaseUrl = mkOption {
      type = types.str;
      description = "Flake URL base (e.g., github:user/repo).";
    };

    testTag = mkOption {
      type = types.str;
      default = "deploy-test";
      description = "Tag that triggers nixos-rebuild test.";
    };

    switchTag = mkOption {
      type = types.str;
      default = "deploy-switch";
      description = "Tag that triggers nixos-rebuild switch.";
    };

    hostname = mkOption {
      type = types.str;
      default = config.networking.hostName;
    };

    interval = mkOption {
      type = types.str;
      default = "*:0/5"; # Every 5 minutes
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/auto-deployer";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nixos-tag-updater = {
      description = "Poll Git for Test and Switch tags";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${deployScript}/bin/deploy-tags";
        User = "root";
      };
    };

    systemd.timers.nixos-tag-updater = {
      description = "Timer for NixOS Tag Updater";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
  };
}
