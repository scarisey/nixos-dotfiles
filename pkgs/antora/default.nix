{ lib, buildNpmPackage, fetchFromGitLab, fetchNpmDeps, jq, buildEnv, npmHooks }:
let
  pname = "antora";
  version = "3.1.7";
  originalFiles = fetchFromGitLab {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uGXXp6boS5yYsInSmkI9S0Tn85QGVp/5Fsh1u3G4oPk=";
  };
  modifiedLock = ./package-lock.json;
  npmDepsHash = "";
  mermaid-extension-version = "~0.0.4";
in

buildNpmPackage rec {
  inherit pname version modifiedLock originalFiles npmDepsHash;
  src = originalFiles;

  mermaid_extension = fetchNpmDeps {
    name = "@sntke/antora-mermaid-extension";
    hash = "";
  };

  postPatch = ''
    # This is to stop tests from being ran, as some of them fail due to trying to query remote repositories
      substituteInPlace package.json --replace \
        '"_mocha"' '""'
      (
        local postPatchHooks=() # written to by npmConfigHook
        source ${npmHooks.npmConfigHook}/nix-support/setup-hook
        npmRoot="${src}/antora-mermaid-extension"     npmDeps=${mermaid_extension}     npmConfigHook
      )
  '';

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/antora-build/packages/cli/bin/antora $out/bin/antora
  '';

  meta = with lib; {
    description = "A modular documentation site generator. Designed for users of Asciidoctor.";
    homepage = "https://antora.org";
    license = licenses.mpl20;
    #    maintainers = [ maintainers.ehllie ]; # copied from Nixpkgs
  };
}
