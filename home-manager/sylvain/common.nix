{
  outputs,
  inputs,
  ...
}: {
  imports =
    builtins.attrValues outputs.homeManagerModules
    ++ [inputs.sops-nix.homeManagerModules.sops inputs.android-nixpkgs.hmModule];

  nixpkgs = {
    overlays =
      builtins.attrValues outputs.overlays
      ++ [
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

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
