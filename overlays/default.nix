{inputs, ...}:
{
  additions = final: prev: let
    unstable = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
    };
  in
    import ../pkgs {pkgs = final;}
    // {
      darktable = unstable.darktable;
      devenv = unstable.devenv;
      ghostty = inputs.ghostty.packages.${final.system}.default;
      headroom-cli = inputs.headroom.packages.${final.system}.default;
      immich-unstable = unstable.immich;
      llama-cpp-rocm = unstable.llama-cpp-rocm;
      llama-cpp = unstable.llama-cpp;
      mistralVibe = inputs.mistral-vibe.packages.${final.system}.default;
      opencode = unstable.opencode;
      plex = unstable.plex;
      tuios = inputs.tuios.packages.${final.system}.default;
      windsurf = unstable.windsurf;
      zed-editor = unstable.zed-editor;
    };

  modifications = final: prev: {};
}
// {homelab-nix-overlay = inputs.homelab-nix.overlays.default;}
// {herdr-overlay = inputs.herdr.overlays.default;}
