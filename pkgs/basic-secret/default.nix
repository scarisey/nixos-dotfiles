{
  pkgs,
  stdenv,
  buildFHSEnv,
  ...
}: let
  basic-secret = stdenv.mkDerivation {
    pname = "basic-secret";
    version = "0.1";

    src = pkgs.fetchurl {
      url = "https://github.com/scarisey/basic-secret/releases/download/0.1/secret";
      sha256 = "sha256-w7pk/xaP++qcut96t7fFsRdr+A8s8hfzpD5jWVgspRM=";
      executable = true;
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp $src $out/bin/basic-secret
      chmod +x $out/bin/basic-secret
      runHook postInstall
    '';
  };
in
  buildFHSEnv {
    name = "secret";
    targetPkgs = pkgs: [basic-secret];
    runScript = "basic-secret";
  }
