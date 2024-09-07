{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.scarisey.bootanimation;
in {
  options.scarisey.bootanimation.enable = mkEnableOption "Enable boot animation.";
  config = mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "abstract_ring";
        themePackages = with pkgs; [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = ["abstract_ring"];
          })
        ];
      };

      # Enable "Silent Boot"
      # consoleLogLevel = 0;
      # initrd.verbose = false;
      # kernelParams = [
      #   "quiet"
      #   "splash"
      #   "boot.shell_on_fail"
      #   "loglevel=3"
      #   "rd.systemd.show_status=false"
      #   "rd.udev.log_level=3"
      #   "udev.log_priority=3"
      # ];
      # # Hide the OS choice for bootloaders.
      # # It's still possible to open the bootloader list by pressing any key
      # # It will just not appear on screen unless a key is pressed
      # loader.timeout = 0;
    };
  };
}
