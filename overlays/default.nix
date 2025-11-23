{inputs, ...}: {
  additions = final: prev: let
    unstable = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
    };
  in
    import ../pkgs {pkgs = final;}
    // {
      copilotCli = inputs.copilot-cli.packages.${final.system}.default;
      darktable = unstable.darktable;
      immich-unstable = unstable.immich;
      ghostty = inputs.ghostty.packages.${final.system}.default;
      plex = unstable.plex;
      windsurf = unstable.windsurf;
    };

  modifications = final: prev: {};
}
