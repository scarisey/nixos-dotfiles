# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    jdk = final.jdk21;
    jdk_headless = final.jdk21_headless;
    jre = final.jdk;
    jre_headless = final.jdk_headless;

    # stable = import inputs.nixpkgs-stable {
    #   system = final.system;
    #   config.allowUnfree = true;
    # };
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
}
