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
    intellij = mkEnableOption "Include Intellij Idea community edition";
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
        #jvm
        jdk
        sbt
        scala-cli
        coursier
        maven
        gradle
        #others
        nodejs
        cargo
      ]
      ++ optionals cfg.intellij [
        jetbrains.idea-community
      ];

      home.sessionVariables = {
        JAVA_HOME = "${pkgs.jdk}";
      };

      home.activation.npmSetPrefix = hm.dag.entryAfter [ "reloadSystemd" ] "$DRY_RUN_CMD ${config.home.path}/bin/npm $VERBOSE_ARG set prefix ${npmGlobalDir}"; #then npm -g install should work
    };
}
