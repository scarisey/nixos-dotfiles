{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.android;
in {
  options.scarisey.android = {
    enable = mkEnableOption "Android config";
  };

  config = mkIf cfg.enable {
    android-sdk.enable = true;

    # Optional; default path is "~/.local/share/android".
    android-sdk.path = "${config.home.homeDirectory}/Android/Sdk";

    #List available packages: nix flake show github:tadfisher/android-nixpkgs
    android-sdk.packages = sdk:
      with sdk; [
        build-tools-34-0-0
        cmdline-tools-latest
        emulator
        platform-tools
        platforms-android-34
        sources-android-34
        system-images-android-34-google-apis-playstore-x86-64
      ];

    home.packages = [
      pkgs.androidStudioPackages.stable
    ];
  };
}
