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
    android-sdk.path = "${config.home.homeDirectory}/.android/sdk";

    #List available packages: nix flake show github:tadfisher/android-nixpkgs
    android-sdk.packages = sdk:
      with sdk; [
        build-tools-35-0-0
        cmdline-tools-latest
        emulator
        platform-tools
        platforms-android-35
        sources-android-35
      ];

    home.packages = [
      pkgs.androidStudioPackages.stable
    ];
  };
}
