# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  acme = import ./acme.nix;
  bootanimation = import ./bootanimation.nix;
  i3Xfce = import ./i3.nix;
  kde = import ./kde.nix;
  gnome = import ./gnome.nix;
  cloud = import ./cloud.nix;
  distrobox = import ./distrobox.nix;
  qemu = import ./qemu.nix;
  network = import ./network.nix;
  vpn = import ./vpn.nix;
}
