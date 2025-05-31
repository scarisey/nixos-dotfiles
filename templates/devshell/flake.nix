{
  description = "Development shell for non-Nix software";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";

    # For Non Nixos systems
    nixgl.url = "github:guibou/nixGL";

    # For secrets encryption
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
    self,
    nixpkgs,
    nixgl,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
    ];
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nixgl.overlay];
          config = {
            # Allow unfree packages
            allowUnfree = true;
            # Allow packages with non-commercial licenses
            allowNonCommercial = true;
          };
        };

        # Add your non-Nix software dependencies here
        nonNixDependencies = with pkgs; [
          # Libraries commonly needed for running non-Nix binaries
          glibc
          gcc-unwrapped.lib
          zlib
          stdenv.cc.cc.lib

          # X11 libraries
          xorg.libX11
          xorg.libXcursor
          xorg.libXrandr
          xorg.libXi

          # OpenGL
          libGL

          # Audio
          alsa-lib
          pulseaudio

          # Add more dependencies as needed
        ];
      in {
        default = pkgs.mkShell {
          packages = with pkgs;
            [
              # Add development tools here
              git
              curl
              wget

              # Add more tools as needed
            ]
            ++ nonNixDependencies;

          # Set environment variables
          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath nonNixDependencies}:$LD_LIBRARY_PATH
            export PATH=$PATH:$PWD/bin

            # Create a bin directory if it doesn't exist
            mkdir -p $PWD/bin

            echo "Development shell for non-Nix software initialized!"
            echo "Place your non-Nix binaries in the ./bin directory"
          '';
        };
      }
    );
  };
}
