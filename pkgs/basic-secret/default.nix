{pkgs, ...}: let
  pname = "basic-secret";
  version = "0.1";
in
  pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://github.com/scarisey/basic-secret/releases/download/0.1/secret";
      sha256 = "sha256-w7pk/xaP++qcut96t7fFsRdr+A8s8hfzpD5jWVgspRM=";
      executable = true;
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/secret
      chmod +x $out/bin/secret
    '';
  }
