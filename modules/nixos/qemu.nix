{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.qemu;
in {
  options.scarisey.qemu = {
    enable = mkEnableOption "QEmu config.";
  };
  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    environment.systemPackages = with pkgs.unstable; [
      qemu
      virt-manager
    ];
  };
}
