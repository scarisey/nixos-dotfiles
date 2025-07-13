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
      windsurf = unstable.windsurf;
    };

  modifications = final: prev: {};
}
