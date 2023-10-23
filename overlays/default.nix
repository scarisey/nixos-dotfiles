# This file defines overlays
{ inputs, ... }:
let
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
      overlays = [ (import ./unstable.nix) ];
    };
  };
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
    let
      pkgsUnstable = (unstable-packages final prev).unstable;
      jdk = pkgsUnstable.temurin-bin-17;
      jre = final.jdk;
    in
    {
      inherit jdk jre;

      # example = prev.example.overrideAttrs (oldAttrs: rec {
      # ...
      # });
    };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  inherit unstable-packages;
}
