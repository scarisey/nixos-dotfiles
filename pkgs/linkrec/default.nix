{ stdenv, lib, bash, makeWrapper, coreutils, findutils, gnused, ... }:
let
  fs = lib.fileset; #check https://nix.dev/tutorials/file-sets
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
stdenv.mkDerivation rec {
  pname = "linkrec";
  version = "1.0";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash coreutils findutils gnused ];

  postInstall = ''
    wrapProgram $out/bin/linkrec \
      --set PATH ${lib.makeBinPath buildInputs}
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp linkrec $out/bin/linkrec
    chmod a+x $out/bin/linkrec
    runHook postInstall
  '';
}
