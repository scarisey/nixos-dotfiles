{ stdenv, lib, bash, makeWrapper, coreutils, findutils, ... }:
let
  fs = lib.fileset; #check https://nix.dev/tutorials/file-sets
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
stdenv.mkDerivation {
  pname = "linkrec";
  version = "1.0";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash coreutils findutils ];

  postInstall = ''
    wrapProgram $out/bin/linkrec \
      --set PATH ${lib.makeBinPath [
        coreutils
        findutils
      ]}
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp linkrec $out/bin/linkrec
    chmod a+x $out/bin/linkrec
    runHook postInstall
  '';
}
