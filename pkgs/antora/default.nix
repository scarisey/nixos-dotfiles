{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  buildEnv,
}: let
  source = lib.importJSON ./source.json;
in
  buildNpmPackage {
    pname = "antora";
    inherit (source) version;
    src = fetchurl {
      url = "https://registry.npmjs.org/antora/-/${source.filename}";
      hash = source.integrity;
    };

    postPatch = ''
      rm package.json
      ln -s ${./package.json} package.json
      ln -s ${./package-lock.json} package-lock.json
    '';

    npmDepsHash = source.deps;

    makeCacheWritable = true;
    dontNpmBuild = true;
    dontNpmInstall = false;
    npmFlags = ["--omit=optional"];

    passthru.updateScript = ./update.sh;

    meta = with lib; {
      description = "A modular documentation site generator. Designed for users of Asciidoctor.";
      homepage = "https://antora.org";
      license = licenses.mpl20;
    };
  }
