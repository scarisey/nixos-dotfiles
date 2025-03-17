{...}: {
  services.github-runners = {
    hyperion-runner = {
      enable = true;
      name = "hyperion";
      tokenFile = "/var/gh-runner/token";
      url = "https://github.com/scarisey/nixos-dotfiles";
    };
  };
}
