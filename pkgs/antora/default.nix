{ lib, buildNpmPackage, fetchFromGitLab, jq, buildEnv }:
let
  pname = "antora";
  version = "3.1.5";
  originalFiles = fetchFromGitLab {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-PCtYV5jPGFja26Dv4kXiaw8ITWR4xzVP/9hc45UWHeg=";
  };
  modifiedLock = ./package-lock.json;
in

buildNpmPackage rec {
  inherit pname version modifiedLock originalFiles;
  src = originalFiles;

  npmDepsHash = "sha256-1C26WWa1UXVcWVnDewULV40GjRTekWEp9daJauCZoK0=";

  # This is to stop tests from being ran, as some of them fail due to trying to query remote repositories
  postPatch = ''
    cp ${modifiedLock} package-lock.json
    substituteInPlace package.json --replace \
      '"_mocha"' '""'
    tmpfile=$(mktemp)
    echo $tmpfile
    ${jq}/bin/jq '.dependencies."@sntke/antora-mermaid-extension" = "~0.0.4"' ./package.json > $tmpfile
    cp $tmpfile package.json
  '';

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/antora-build/packages/cli/bin/antora $out/bin/antora
  '';

  meta = with lib; {
    description = "A modular documentation site generator. Designed for users of Asciidoctor.";
    homepage = "https://antora.org";
    license = licenses.mpl20;
    maintainers = [ maintainers.ehllie ];
  };
}
