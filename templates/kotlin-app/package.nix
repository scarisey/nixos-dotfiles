{
  lib,
  stdenv,
  makeWrapper,
  gradle,
  jre_minimal,
  name,
  version,
  ...
}:let 
  self = stdenv.mkDerivation (finalAttrs: {
  pname = name;
  inherit version;

  src = ./.;
  nativeBuildInputs = [ gradle makeWrapper ];

  #write deps.json with : nix build .\#packages.x86_64-linux.default.mitmCache.updateScript && ./result
  mitmCache = gradle.fetchDeps {
    pkg = self;
    data = ./deps.json;
  };

  __darwinAllowLocalNetworking = true;

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleBuildTask = "shadowJar";

  doCheck = false;#true for gradle test

  installPhase = ''
    mkdir -p $out/{bin,share/${name}}
    cp app/build/libs/app.jar $out/share/${name}/

    makeWrapper ${jre_minimal}/bin/java $out/bin/${name} \
      --add-flags "-jar $out/share/${name}/app.jar"
  '';

  meta.sourceProvenance = with lib.sourceTypes; [
    fromSource
    binaryBytecode # mitm cache
  ];
}); in self
