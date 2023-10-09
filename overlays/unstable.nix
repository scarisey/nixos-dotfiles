final: prev: {
  jdk = final.temurin-bin-17;
  jre = final.jdk;

  sbt = prev.sbt.overrideAttrs (finalAttrs: prevAttrs: rec {
    version = "1.9.4";

    postPatch = ''
      echo -java-home ${final.jdk.home} >>conf/sbtopts
    '';

    src = builtins.fetchurl {
      url = "https://github.com/sbt/sbt/releases/download/v${version}/sbt-${version}.tgz";
      sha256 = "0w5qkbrdfhi72l9029dv45vf8sczj457gdi5zcn9p8wxq8jh5gb8"; #nix-prefetch-url --type sha256 ${url}
    };

  });
}

