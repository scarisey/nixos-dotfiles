{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.scarisey.kde;
in {
  options.scarisey.kde = {
    enable = mkEnableOption "KDE settings";
  };
  config = mkIf cfg.enable {
    # FIX: deduplicate entries in XDG_DATA_DIRS (performance impact)
    home.sessionVariablesExtra = ''
      if [ -n "$XDG_DATA_DIRS" ]; then
        XDG_DATA_DIRS=$(echo "$XDG_DATA_DIRS" | tr ':' '\n' | awk '!seen[$0]++' | paste -sd: -)
        export XDG_DATA_DIRS
      fi
    '';
  };
}
