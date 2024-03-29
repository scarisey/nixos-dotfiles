{
  stdenv,
  lib,
  bash,
  makeWrapper,
  coreutils,
  curl,
  mtr,
  ...
}: let
  fs = lib.fileset;
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
  stdenv.mkDerivation {
    pname = "testdebits";
    version = "1.0";

    src = fs.toSource {
      root = ./.;
      fileset = sourceFiles;
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [bash coreutils curl mtr];

    postInstall = ''
      wrapProgram $out/bin/testdebits \
        --set PATH ${lib.makeBinPath [
        coreutils
        curl
        mtr
      ]}
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp testdebits $out/bin/testdebits
      chmod a+x $out/bin/testdebits
      runHook postInstall
    '';
  }
