{
  stdenv,
  lib,
  zsh,
  git,
  makeWrapper,
  coreutils,
  openssh,
  nix,
  ...
}: let
  fs = lib.fileset; #check https://nix.dev/tutorials/file-sets
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
  stdenv.mkDerivation {
    pname = "update-nix";
    version = "1.0";

    src = fs.toSource {
      root = ./.;
      fileset = sourceFiles;
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [git zsh coreutils nix];

    postInstall = ''
      wrapProgram $out/bin/update-nix \
        --set PATH ${lib.makeBinPath [
        coreutils
        git
        openssh
        nix
      ]}
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp update-nix $out/bin/update-nix
      chmod a+x $out/bin/update-nix
      runHook postInstall
    '';
  }
