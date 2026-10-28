{
  pkgs,
  ...
}: {
  services.harness-jail = {
    enable = true;
    package = pkgs.opencode;
    command = "opencode";
    enableNetwork = true;
    args = [];
    clearEnv = true;
    daemon = false;
    readWritePaths = [ "/home/sylvain/git" ];
  };
}
