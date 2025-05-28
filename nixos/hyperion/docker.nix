{...}: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = "overlay2";
    autoPrune = {
      enable = true;
      dates = "Fri *-*-* 05:00:00";
    };
  };
}
