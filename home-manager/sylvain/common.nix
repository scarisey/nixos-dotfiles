{
  outputs,
  inputs,
  ...
}: {
  imports =
    builtins.attrValues outputs.homeManagerModules
    ++ [inputs.sops-nix.homeManagerModules.sops inputs.stylix.homeManagerModules.stylix inputs.android-nixpkgs.hmModule];

  nixpkgs = {
    overlays =
      (builtins.attrValues outputs.overlays)
      ++ [
        inputs.nix-alien.overlays.default
        inputs.android-nixpkgs.overlays.default
      ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  programs.home-manager.enable = true;
  home.username = "sylvain";
  home.homeDirectory = "/home/sylvain";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
