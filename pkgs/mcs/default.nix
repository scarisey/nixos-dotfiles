{
  lib,
  pkgs,
  stdenv,
  buildFHSEnv,
  ...
}: let
  mcs-dev = stdenv.mkDerivation {
    pname = "mcs-dev";
    version = "0.7.2";

    src = pkgs.fetchzip {
      url = "https://github.com/mthmulders/mcs/releases/download/v0.7.2/mcs-0.7.2-linux-x86_64.tar.gz";
      hash = "sha256-lEiPzVFs/Fq3HeCKOj/NE9oPBOTnZdbQRuJNKkxbMl0=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp $src/bin/mcs $out/bin/mcs
      chmod a+x $out/bin/mcs
      runHook postInstall
    '';
  };
in
  buildFHSEnv {
    name = "mcs";
    targetPkgs = pkgs: [mcs-dev];
    runScript = "mcs";
    platforms = lib.platforms."x86_64-linux";
  }
