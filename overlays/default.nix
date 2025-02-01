{inputs, ...}: {
  additions = final: prev: import ../pkgs {pkgs = final;} // {ghostty = inputs.ghostty.packages.${final.system}.default;};

  modifications = final: prev: {
    jdk = final.jdk21;
    jdk_headless = final.jdk21_headless;
    jre = final.jdk;
    jre_headless = final.jdk_headless;
  };
}
