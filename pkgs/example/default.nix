#debug building by following manual: https://nixos.org/manual/nixpkgs/stable/#sec-building-stdenv-package-in-nix-shell
{
  stdenv,
  lib,
  bash,
  makeWrapper,
  coreutils,
  jq,
  yq,
  ...
}: let
  fs = lib.fileset; #check https://nix.dev/tutorials/file-sets
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
  stdenv.mkDerivation {
    pname = "scriptExample";
    version = "1.0";

    src = fs.toSource {
      root = ./.;
      fileset = sourceFiles;
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [bash coreutils jq yq];

    postInstall = ''
      wrapProgram $out/bin/scriptExample \
        --set PATH ${lib.makeBinPath [
        coreutils
        jq
      ]}
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp scriptExample $out/bin/scriptExample
      chmod a+x $out/bin/scriptExample
      runHook postInstall
    '';
  }
