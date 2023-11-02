{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.scarisey.asciidoctor;
in
{
  options.scarisey.asciidoctor = {
    enable = mkEnableOption "asciidoctor settings";
  };
  config = mkIf cfg.enable {

    home.file.".local/bin/asciidoctor" = {
      source = ./asciidoctor/asciidoctor.sh;
      executable = true;
    };

  };
}
