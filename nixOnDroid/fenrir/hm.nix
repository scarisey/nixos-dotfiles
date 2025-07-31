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

  home.stateVersion = "24.05";
  home.username = "nix-on-droid";
  home.homeDirectory = "/data/data/com.termux.nix/files/home";
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = "${inputs.private-vault}/secrets.yaml";
    secrets."private_git_config/config".path = "${config.home.homeDirectory}/.private.gitconfig";
    secrets."private_git_config/user".path = "${config.home.homeDirectory}/.private.gituser";
    secrets.private_ssh_config.path = "${config.home.homeDirectory}/.ssh/private_config";
  };

  programs.home-manager.enable = true;

  scarisey.myshell.enable = true;
  scarisey.devtools.enable = true;
  scarisey.autoUpdate = {
    enable = true;
    dates = "Fri *-*-* 04:30:00";
    flake = "github:scarisey/nixos-dotfiles";
  };
}
