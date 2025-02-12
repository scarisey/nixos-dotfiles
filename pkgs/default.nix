# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs}: {
  adoc = pkgs.callPackage ./adoc {};
  antora = pkgs.callPackage ./antora {};
  basic-secret = pkgs.callPackage ./basic-secret {};
  git-prune = pkgs.callPackage ./git-prune {};
  glab-tools = pkgs.callPackage ./glab-tools {};
  graalvm-21 = pkgs.callPackage ./graalvm-21 {};
  mcs = pkgs.callPackage ./mcs {};
  msgconvert = pkgs.callPackage ./msgconvert {};
  scriptExample = pkgs.callPackage ./example {};
}
