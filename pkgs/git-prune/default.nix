{ lib
, python3Packages
, git
, openssh
}:let
  fs = lib.fileset;
  sourceFiles = fs.difference ./. (fs.maybeMissing ./result);
in python3Packages.buildPythonApplication {
  pname = "git-prune";
  version = "0.1";
  pyproject = true;

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    gitpython
  ];

  buildInputs = [
    git
    openssh
  ];

  meta = with lib; {
    description = "Customized git prune";
    homepage = "https://github.com/scarisey/git-prune";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "git-prune";
  };
}
