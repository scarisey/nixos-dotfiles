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
    jvm = mkEnableOption "JVM dev tools";
    javascript = mkEnableOption "Javascript dev tools";
    rust = mkEnableOption "Rust dev tools";
    go = mkEnableOption "Go dev tools";
    protobuf = mkEnableOption "Protobuf tools";
    antora = mkEnableOption "Antora";
    android = mkEnableOption "Android";
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
          ]
          ++ optionals (cfg.jvm || cfg.all) [
            jdk
            sbt
            scala-cli
            coursier
            maven
            gradle
          ]
          ++ optionals (cfg.javascript || cfg.all) [
            nodejs
            nodePackages."fx"
          ]
          ++ optionals (cfg.rust || cfg.all) [
            rustup
          ]
          ++ optionals (cfg.intellij) [
            jetbrains-toolbox
          ]
          ++ optionals (cfg.vscode) [
            vscode-fhs
          ]
          ++ optionals (cfg.go || cfg.all) [
            go
          ]
          ++ optionals (cfg.protobuf || cfg.all) [
            protobuf
          ]
          ++ optionals (cfg.antora || cfg.all) [
            antora
          ];
      }
      (mkIf (cfg.javascript || cfg.all) {
        home.activation.npmSetPrefix = hm.dag.entryAfter ["reloadSystemd"] "$DRY_RUN_CMD ${config.home.path}/bin/npm $VERBOSE_ARG set prefix ${npmGlobalDir}"; #then npm -g install should work
      })

      (mkIf (cfg.jvm || cfg.all) {
        home.sessionVariables = {
          JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
        };
        home.file.".jdks/current".source = "${pkgs.jdk}/lib/openjdk";
      })
    ]);
}
