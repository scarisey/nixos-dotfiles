{
  outputs,
  inputs,
  config,
  ...
}: {
  imports =
    builtins.attrValues outputs.homeManagerModules
    ++ [inputs.sops-nix.homeManagerModules.sops inputs.android-nixpkgs.hmModule];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = "${inputs.private-vault}/secrets.yaml";
    secrets."private_git_config/config".path = "${config.home.homeDirectory}/.private.gitconfig";
    secrets."private_git_config/user".path = "${config.home.homeDirectory}/.private.gituser";
    secrets.private_ssh_config.path = "${config.home.homeDirectory}/.ssh/private_config";
  };

  programs.home-manager.enable = true;
  home.username = "sylvain";
  home.homeDirectory = "/home/sylvain";

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
