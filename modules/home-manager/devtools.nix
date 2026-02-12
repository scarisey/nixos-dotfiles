{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  # Shorter name to access final settings a
  # user of devtools.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.scarisey.devtools;
in {
  options.scarisey.devtools = {
    enable = mkEnableOption "Collection of development tools";
    all = mkEnableOption "All tools installed (no IDE)";
    intellij = mkEnableOption "Include Intellij Toolbox";
    vscode = mkEnableOption "Include VSCode";
    zed = mkEnableOption "Include Zed";
    jvm = mkEnableOption "JVM dev tools";
    jdkPkg = mkOption {
      type = lib.types.package;
      default = pkgs.jdk;
      example = "pkgs.jdk_21";
      description = "Set the default JDK (JAVA_HOME, jdks/.current).";
    };
    javascript = mkEnableOption "Javascript dev tools";
    rust = mkEnableOption "Rust dev tools";
    go = mkEnableOption "Go dev tools";
    protobuf = mkEnableOption "Protobuf tools";
    antora = mkEnableOption "Antora";
    android = mkEnableOption "Android";
    duckdb = mkEnableOption "DuckDB";
    mistralVibe = mkEnableOption "Mistral Vibe CLI";
    snowflakeCli = mkEnableOption "Snowflake CLI";
    nixgl = {
      enable = mkEnableOption "Enable NixGL wrappers";
      defaultWrapper = mkOption {
        type = lib.types.enum (builtins.attrNames config.lib.nixGL.wrappers);
        default = "mesa";
      };
    };
  };
  config = let
    npmGlobalDir = "$HOME/.npm-global";
  in
    mkIf cfg.enable (mkMerge [
      {
        scarisey.android.enable = cfg.android;
        home.packages = with pkgs;
          [
            #c
            gcc
            glibc
            #lua
            lua
            luarocks
            #github cli
            gh
            #gitlab cli
            glab
            #made by cachix templates for dev environments
            devenv
            #markdown linter
            rumdl
            #Nix LSP
            nixd
          ]
          ++ optionals (cfg.jvm || cfg.all) [
            jdk
            sbt
            scala-cli
            coursier
            maven
            gradle
            cfr #decompiler
          ]
          ++ optionals (cfg.javascript || cfg.all) [
            nodejs
          ]
          ++ optionals (cfg.rust || cfg.all) [
            rustup
          ]
          ++ optionals (cfg.intellij) [
            (config.lib.nixGL.wrap jetbrains-toolbox)
          ]
          ++ optionals (cfg.vscode) [
            (config.lib.nixGL.wrap vscode-fhs)
            sqlfluff
          ]
          ++ optionals (cfg.zed) [
            (config.lib.nixGL.wrap vscode-fhs)
            zed-editor
          ]
          ++ optionals (cfg.go || cfg.all) [
            go
          ]
          ++ optionals (cfg.protobuf || cfg.all) [
            protobuf
          ]
          ++ optionals (cfg.antora || cfg.all) [
            antora
          ]
          ++ optionals (cfg.duckdb || cfg.all) [
            duckdb
          ]
          ++ optionals (cfg.mistralVibe || cfg.all) [
            mistralVibe
          ];
      }
      (mkIf cfg.enable {
        home.file.".claude/CLAUDE.md".source = ./llm/CLAUDE.md;
        home.file.".config/Code/User/prompts/CLAUDE.md.instructions.md".source = ./llm/CLAUDE.md;
      })
      (mkIf (cfg.javascript || cfg.all) {
        home.activation.npmSetPrefix = hm.dag.entryAfter ["reloadSystemd"] "$DRY_RUN_CMD ${config.home.path}/bin/npm $VERBOSE_ARG set prefix ${npmGlobalDir}"; #then npm -g install should work
      })

      (mkIf (cfg.jvm || cfg.all) {
        home.sessionVariables = {
          JAVA_HOME = "${cfg.jdkPkg}/lib/openjdk";
        };
        home.file.".jdks/current".source = "${cfg.jdkPkg}/lib/openjdk";
      })
    ]);
}
