{ pkgs, lib, config, ... }:
with lib;
let
  # Shorter name to access final settings a 
  # user of devtools.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.scarisey.devtools; in
{
  options.scarisey.devtools = {
    enable = mkEnableOption "Collection of development tools";
    all = mkEnableOption "All tools installed";
    intellij = mkEnableOption "Include Intellij Idea community edition";
    jvm = mkEnableOption "JVM dev tools";
    javascript = mkEnableOption "Javascript dev tools";
    rust = mkEnableOption "Rust dev tools";
    go = mkEnableOption "Go dev tools";
    protobuf = mkEnableOption "Protobuf tools";
  };
  config =
    let
      npmGlobalDir = "$HOME/.npm-global";
    in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        #c
        gcc
        glibc
        #lua
        lua
        luarocks
      ] ++ optionals (cfg.jvm || cfg.all) [
        jdk
        unstable.sbt
        unstable.scala-cli
        unstable.coursier
        maven
        gradle
      ] ++ optionals (cfg.javascript || cfg.all) [
        nodejs
        nodePackages."fx"
      ] ++ optionals (cfg.rust || cfg.all) [
        cargo
      ]
      ++ optionals (cfg.intellij || cfg.all) [
        unstable.jetbrains.idea-community
      ]
      ++ optionals (cfg.go || cfg.all) [
        go
      ]
      ++ optionals (cfg.protobuf || cfg.all) [
        protobuf
      ];

      home.sessionVariables = mkIf (cfg.jvm || cfg.all) {
        JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
      };
      home.file.".jdks/current".source = "${pkgs.jdk}/lib/openjdk";

      home.activation.npmSetPrefix = hm.dag.entryAfter [ "reloadSystemd" ] "$DRY_RUN_CMD ${config.home.path}/bin/npm $VERBOSE_ARG set prefix ${npmGlobalDir}"; #then npm -g install should work
    };
}
