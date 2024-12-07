{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        name = "Application name";
        version = "1.0";
        jdk = pkgs.jdk21;
      in {
        packages.default = pkgs.callPackage ./package.nix {inherit name version jdk;};
        packages.dockerImage = pkgs.dockerTools.buildImage {
          inherit name;
          tag = version;
          config.Cmd = ["${self'.packages.default}/bin/${name}"];
        };
        devenv.shells.default = {
          dotenv.enable = true;
          dotenv.filename = ".env.local";

          languages.kotlin.enable = true;
          languages.java.enable = true;
          languages.java.jdk.package = jdk;
          languages.java.gradle.enable = true;
        };
      };
    };
}
