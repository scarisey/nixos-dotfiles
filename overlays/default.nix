# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # When applied, the unstable nixpkgs set (declared in the flake inputs) will
    # be accessible through 'pkgs.unstable'
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
      overlays = [(import ./unstable.nix)];
    };

    jdk = final.jdk21;
    jdk_headless = final.jdk21_headless;
    jre = final.jdk;
    jre_headless = final.jdk_headless;

    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
}
