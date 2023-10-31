{ pkgs ? import <nixpkgs> { } }:
(pkgs.buildFHSUserEnv (pkgs.appimageTools.defaultFhsEnvArgs // {
  name = "dev";
  runScript = "zsh";
})).env
