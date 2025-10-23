{
  stdenv,
  fetchurl,
  graalvmCEPackages,
}:
graalvmCEPackages.buildGraalvm {
  useMusl = true;
  src = fetchurl {
    sha256 = "sha256-sEgGmqo6mbhPW5V7FizBgaMqQzDLw1QCdmNjxb52rkg=";
    url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-21.0.2/graalvm-community-jdk-21.0.2_linux-x64_bin.tar.gz";
  };
  version = "21.0.2";
  meta.platforms = ["x86_64-linux"];
}
