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
      copilotCli = inputs.copilot-cli.packages.${final.system}.default;
      mistralVibe = inputs.mistral-vibe.packages.${final.system}.default;
      opencode = unstable.opencode;
      darktable = unstable.darktable;
      devenv = unstable.devenv;
      immich-unstable = unstable.immich;
      ghostty = inputs.ghostty.packages.${final.system}.default;
      plex = unstable.plex;
      windsurf = unstable.windsurf;
      zed-editor = unstable.zed-editor;
      llama-cpp = unstable.llama-cpp;
      llama-cpp-rocm = unstable.llama-cpp-rocm;
    };

  modifications = final: prev: {};
}
// {homelab-nix-overlay = inputs.homelab-nix.overlays.default;}
