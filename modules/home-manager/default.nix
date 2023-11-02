# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.

{
  # List your module files here
  # my-module = import ./my-module.nix;
  gui = import ./gui.nix;
  devtools = import ./devtools.nix;
  myshell = import ./myshell.nix;
  i3Xfce = import ./i3Xfce;
  quickemu = import ./quickemu.nix;
  cloud = import ./cloud.nix;
  kde = import ./kde.nix;
  asciidoctor = import ./asciidoctor.nix;
}
