# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    jdk = prev.temurin-bin-17;
    jre = final.jdk;
    sbt = prev.sbt.overrideAttrs (finalAttrs: prevAttrs: rec {
      version = "1.9.4";

      postPatch = ''
        echo -java-home ${final.jdk.home} >>conf/sbtopts
      '';

      src = builtins.fetchurl {
        url = "https://github.com/sbt/sbt/releases/download/v${version}/sbt-${version}.tgz";
        sha256 = "0w5qkbrdfhi72l9029dv45vf8sczj457gdi5zcn9p8wxq8jh5gb8"; #nix-prefetch-url --type sha256 ${url}
      };

    });
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
