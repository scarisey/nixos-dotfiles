{
  stdenv,
  lib,
  bash,
  makeWrapper,
  coreutils,
  asciidoctor-with-extensions,
  d2,
  ...
}: let
  fs = lib.fileset; #check https://nix.dev/tutorials/file-sets
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
  stdenv.mkDerivation {
    pname = "adoc";
    version = "1.0";

    src = fs.toSource {
      root = ./.;
      fileset = sourceFiles;
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [bash coreutils asciidoctor-with-extensions d2];

    postInstall = ''
      wrapProgram $out/bin/adoc \
        --set PATH ${lib.makeBinPath [
        coreutils
        asciidoctor-with-extensions
        d2
      ]}
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp adoc $out/bin/adoc
      chmod a+x $out/bin/adoc
      runHook postInstall
    '';
  }
