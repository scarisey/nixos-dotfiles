{
  stdenv,
  lib,
  bash,
  makeWrapper,
  coreutils,
  jq,
  parallel,
  glab,
  ghq,
  git,
  openssh,
  ...
}: let
  fs = lib.fileset;
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
  stdenv.mkDerivation {
    pname = "glab-tools";
    version = "1.0";

    src = fs.toSource {
      root = ./.;
      fileset = sourceFiles;
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [bash coreutils jq parallel glab ghq git openssh];

    postInstall = ''
      wrapProgram $out/bin/glab_tools \
        --set PATH ${lib.makeBinPath [
        coreutils
        jq
        parallel
        glab
        ghq
        git
        openssh
      ]}
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp glab_tools $out/bin/glab_tools
      chmod a+x $out/bin/glab_tools
      runHook postInstall
    '';
  }
