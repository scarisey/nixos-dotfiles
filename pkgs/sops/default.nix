{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "sops";
  version = "3.9.1";

  src = fetchFromGitHub {
    owner = "getsops";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-j16hSTi7fwlMu8hwHqCR0lW22VSf0swIVTF81iUYl2k=";
  };

  vendorHash = "sha256-40YESkLSKL/zFBI7ccz0ilrl9ATr74YpvRNrOpzJDew=";

  subPackages = ["cmd/sops"];

  ldflags = ["-s" "-w" "-X github.com/getsops/sops/v3/version.Version=${version}"];

  meta = with lib; {
    homepage = "https://github.com/getsops/sops";
    description = "Simple and flexible tool for managing secrets";
    changelog = "https://github.com/getsops/sops/blob/v${version}/CHANGELOG.rst";
    mainProgram = "sops";
    maintainers = with maintainers; [Scrumplex mic92];
    license = licenses.mpl20;
  };
}
