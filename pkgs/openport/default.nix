{ stdenv
, lib
, bash
, libnatpmp
, makeWrapper
, coreutils
, ...
}:
let
  fs = lib.fileset; #check https://nix.dev/tutorials/file-sets
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in
stdenv.mkDerivation {
  pname = "openport";
  version = "1.0";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash libnatpmp coreutils ];

  postInstall = ''
    wrapProgram $out/bin/openport \
      --set PATH ${lib.makeBinPath [
      libnatpmp
      coreutils
    ]}
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp openport $out/bin/openport
    chmod a+x $out/bin/openport
    runHook postInstall
  '';
}
