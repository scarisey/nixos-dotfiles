{
  description = "SCarisey's dotfiles";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # For unpatched binaries
    nix-alien.url = "github:thiagokokada/nix-alien";
    #For Non Nixos systems
    nixgl.url = "github:guibou/nixGL";

    #For secrets encryption
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixgl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
    ];
    lib' = import ./lib {lib = nixpkgs.lib;};
    forHosts = lib'.forHosts ./nixos;
    forUsers = lib'.forUsers ./home-manager;
  in rec {
    inherit lib';
    lib = nixpkgs.lib;
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    packages = forAllSystems (
      system: let
        overlays = [
          (import ./overlays {inherit inputs;}).modifications
        ];
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./pkgs {inherit pkgs;}
    );
    devShells =
      forAllSystems
      (
        system: let
          overlays = [(import ./overlays {inherit inputs;}).modifications];
          pkgs = import nixpkgs {inherit system overlays;};
        in {
          default = pkgs.mkShell {
            LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
            shellHook = ''
              exec ${pkgs.zsh}/bin/zsh
            '';
          };
        }
      );

    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = forHosts (
      path:
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
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
            overlays = [nixgl.overlay];
          };
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [path];
        }
    );

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://scarisey-public.cachix.org"
    ];
    extra-trusted-public-keys = [
      "scarisey-public.cachix.org-1:kabqlCM0Wwd3iOh+C62WQg7vUO7vX3JbKKraSmxr2n8="
    ];
  };
}
