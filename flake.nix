{
  description = "SCarisey's dotfiles";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";

    #For secrets encryption
    sops-nix.url = "github:Mic92/sops-nix";

    #Android SDK
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";

    #ghostty terminal
    ghostty.url = "github:ghostty-org/ghostty";

    # Mistral Vibe
    mistral-vibe.url = "github:mistralai/mistral-vibe";

    #copilot CLI from a flake of mine
    copilot-cli.url = "github:scarisey/copilot-cli-flake";

    #snowflake CLI from a flake of mine
    snowflake-cli.url = "github:scarisey/snowflake-cli-flake";

    #Homelabe separate module
    homelab-nix.url = "github:scarisey/homelab-nix";

    #Private vault - change for your own when fork
    private-vault = {
      url = "github:scarisey/vault";
    };

    private-modules = {
      url = "github:scarisey/private-nix-modules";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    android-nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
    ];
    lib' = import ./lib {lib = nixpkgs.lib;};
    forHosts = lib'.forHosts ./nixos;
    forUsers = lib'.forUsers ./home-manager;
    overlaysFlake = import ./overlays {inherit inputs;};
    overlays = builtins.attrValues overlaysFlake;
    rev = builtins.tryEval (self.rev or self.dirtyRev or self.dirtyShortRev);
    flakeRev =
      if rev.success
      then rev.value
      else "unknown"; #inspect current flake revision from the system
  in {
    inherit lib';
    lib = nixpkgs.lib;

    overlays = overlaysFlake;
    templates = {
      devshell = {
        path = ./templates/devshell;
        description = "Development shell for running non-Nix software";
      };
    };

    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system overlays;};
      in
        import ./pkgs {inherit pkgs;}
        // {
          default = home-manager.packages.${system}.default;
        }
    );

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = forHosts (
      path:
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs overlays flakeRev;};
          modules = [path];
        }
    );

    homeConfigurations = forUsers (
      {
        user,
        system,
        path,
      }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = overlays ++ [android-nixpkgs.overlays.default];
          };
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [path];
        }
    );

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };

  nixConfig = {
    extra-substituters = [
      "https://ghostty.cachix.org?priority=20"
      "https://nix-community.cachix.org?priority=31"
      "https://scarisey-public.cachix.org?priority=32"
    ];
    extra-trusted-public-keys = [
      "scarisey-public.cachix.org-1:kabqlCM0Wwd3iOh+C62WQg7vUO7vX3JbKKraSmxr2n8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
    ];
  };
}
