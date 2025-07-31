{ pkgs, ...}:
{
  environment.sessionVariables = {
    EDITOR = "nvim";
  };

  environment.etcBackupExtension = ".bak";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  android-integration.termux-setup-storage.enable = true;
	environment.motd = null;

  environment.packages = with pkgs; [
    (pkgs.writeScriptBin "ff" ''exec fastfetch --logo android "$@"'')
    procps
    killall
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    iproute2
    which
  ];

  system.stateVersion = "24.05";

  time.timeZone = "Europe/Paris";
}
