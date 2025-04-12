{inputs, ...}: {
  additions = final: prev: let
    unstable = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
    };
  in
    import ../pkgs {pkgs = final;}
    // {
      ghostty = inputs.ghostty.packages.${final.system}.default;
      plex = unstable.plex;
    };

  modifications = final: prev: {
    jdk = final.jdk21;
    jdk_headless = final.jdk21_headless;
    jre = final.jdk;
    jre_headless = final.jdk_headless;
  };
}
