# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.

{
  # List your module files here
  # my-module = import ./my-module.nix;
  i3Xfce = import ./i3.nix;
  kde = import ./kde.nix;
  cloud = import ./cloud.nix;
  distrobox = import ./distrobox.nix;
}
