# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs}: {
  adoc = pkgs.callPackage ./adoc {};
  antora = pkgs.callPackage ./antora {};
  basic-secret = pkgs.callPackage ./basic-secret {};
  git-prune = pkgs.callPackage ./git-prune {};
  glab-tools = pkgs.callPackage ./glab-tools {};
  msgconvert = pkgs.callPackage ./msgconvert {};
  scriptExample = pkgs.callPackage ./example {};
  testdebits = pkgs.callPackage ./testdebits {};
  openport = pkgs.callPackage ./openport {};
  update-dir = pkgs.callPackage ./update-dir {};
}
