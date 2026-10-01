{
  lib,
  config,
  ...
}: let
  cfg = config.scarisey.harness;
in
  with lib; {
    options = {
      enable = mkEnableOption "Set up a harness server.";
      command = mkOption {
        type = types.listOf types.str;
        description = "Command to launch the harness";
      };
      environmentFile = mkOption {
        description = "Path to environmentFile (systemd unit env file) in string.";
        type = types.str;
      };
    };
    config = mkIf cfg.enable {
      systemd.services.harness = let
        name = "harness";
      in {
        description = "Harness for LLM server";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "idle";
          KillSignal = "SIGINT";
          StateDirectory = name;
          CacheDirectory = name;
          WorkingDirectory = "/var/lib/${name}";
          Environment = [];
          EnvironmentFile = cfg.environmentFile;
          ExecStart = lib.escapeShellArgs cfg.command;
          Restart = "on-failure";
          RestartSec = 300;

          # hardening
          DynamicUser = true;
          CapabilityBoundingSet = "";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          NoNewPrivileges = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          MemoryDenyWriteExecute = true;
          LockPersonality = true;
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "personality"
          ];
          SystemCallErrorNumber = "EPERM";
          ProtectProc = "invisible";
          ProtectHostname = true;
          ProcSubset = "pid";
        };
      };
    };
  }
