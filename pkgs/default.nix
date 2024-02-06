# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs }: {
  adoc = pkgs.callPackage ./adoc { };
  antora = pkgs.callPackage ./antora { };
  basic-secret = pkgs.callPackage ./basic-secret { };
  linkrec = pkgs.callPackage ./linkrec { };
  scriptExample = pkgs.callPackage ./example { };
  win32yank = pkgs.callPackage ./win32yank { };
}
