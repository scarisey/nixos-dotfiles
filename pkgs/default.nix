# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs }: {
  adoc = pkgs.callPackage ./adoc { };
  antora = pkgs.callPackage ./antora { };
  basic-secret = pkgs.callPackage ./basic-secret { };
  linkrec = pkgs.callPackage ./linkrec { };
  msgconvert = pkgs.callPackage ./msgconvert { };
  scriptExample = pkgs.callPackage ./example { };
  sops-latest = pkgs.callPackage ./sops { };
  testdebits = pkgs.callPackage ./testdebits { };
  openport = pkgs.callPackage ./openport { };
}
