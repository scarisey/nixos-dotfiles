{
  description = "Environment to run non-NixOS binaries";

  inputs = {
    upstream.url = "github:scarisey/nixos-dotfiles/main";
    nixpkgs.follows = "upstream/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowNonCommercial = true;
        };
      };
      # Common libraries required for Linux binaries
      commonLibs = with pkgs; [
        # Basic C libraries
        glibc
        stdenv.cc.cc.lib

        # Common system libraries
        zlib
        openssl
        curl
        libxml2
        libxslt
        expat

        # Basic graphics libraries
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libXrandr
        xorg.libXi
        xorg.libXcursor
        xorg.libXinerama
        xorg.libXfixes
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libxcb
        xorg.libXxf86vm
        xorg.libSM
        xorg.libICE

        # GLib/GObject libraries (essential for GTK)
        glib
        gobject-introspection

        # GTK and accessibility libraries
        gtk3
        atk
        at-spi2-atk
        at-spi2-core

        # Graphics rendering libraries
        pango
        cairo

        # Keyboard/mouse support
        libxkbcommon

        # Mozilla/NSS libraries (for web apps)
        nss
        nspr

        # Printing support
        cups

        # Advanced graphics support
        libdrm
        mesa
        libGL

        # Qt
        qt5.qtbase

        # Audio
        alsa-lib
        pulseaudio

        # Other useful libraries
        fontconfig
        freetype
        dbus
        systemd

        # Python and other runtimes
        python3
        nodejs
      ];
    in {
      devShells.default = pkgs.mkShell {
        name = "universal-binary-env";

        buildInputs = with pkgs;
          [
            # nix-ld for running non-Nix binaries
            nix-ld
            steam-run

            # Useful tools
            file
            strace
            patchelf

            # Common libraries
          ]
          ++ commonLibs;

        # Environment variables for nix-ld
        shellHook = ''
          echo "🚀 Universal environment for non-NixOS binaries activated"
          echo "Libraries added for maximum compatibility:"
          echo "  - GLib/GObject (gobject-introspection, glib)"
          echo "  - NSS/Mozilla (nss, nspr for web apps)"
          echo "  - Accessibility (atk, at-spi2-*)"
          echo "  - Graphics rendering (pango, cairo, mesa, libdrm, libGL)"
          echo "  - Keyboard support (libxkbcommon)"
          echo "  - Printing support (cups)"
          echo "  - Extended Xorg (Xcomposite, Xdamage, xcb, Xxf86vm, SM, ICE)"
          echo ""
          echo "Usage:"
          echo "  - Copy your binary into this directory"
          echo "  - Run it directly: ./my-binary"
          echo "  - Or use: nix-ld ./my-binary"
          echo "  - Or use (e.g. from home for chroot to work): steam-run ./my-binary"
          echo ""
          echo "Available tools:"
          echo "  - file: identify file type"
          echo "  - ldd: view dynamic dependencies"
          echo "  - strace: trace system calls"
          echo "  - patchelf: modify linked libraries"
          echo ""

          export NIX_LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath commonLibs}"
          export NIX_LD="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
          export LD_LIBRARY_PATH="$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH"

          echo "Configured variables:"
          echo "  NIX_LD=$NIX_LD"
          echo "  NIX_LD_LIBRARY_PATH set with ${toString (builtins.length commonLibs)} libraries"
          exec ${pkgs.zsh}/bin/zsh
        '';
      };
    });
}
