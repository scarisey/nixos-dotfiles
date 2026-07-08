{
  lib,
  python3,
}:
python3.pkgs.buildPythonApplication {
  pname = "filter-nef-by-rating";
  version = "1.0.0";

  src = ./.; # place default.nix next to filter_nef_by_rating.py

  # Pure stdlib — no runtime deps beyond Python itself
  propagatedBuildInputs = [];

  # No setup.py / pyproject.toml: install the script directly
  format = "other";

  installPhase = ''
    install -Dm755 filter_nef_by_rating.py $out/bin/filter-nef-by-rating
  '';

  # Patch the shebang to point at the Nix store Python
  postFixup = ''
    patchShebangs $out/bin/filter-nef-by-rating
  '';

  meta = {
    description = "Filter NEF files by their darktable XMP sidecar rating";
    longDescription = ''
      Scans a directory (optionally recursive) for NEF raw files and
      reads the accompanying darktable XMP sidecar to filter by rating
      (-1 rejected, 0 unrated, 1-5 stars).  Matched files can be
      printed, symlinked, or hard-linked into an output directory.
      Fully non-destructive: source files are never modified.
    '';
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "filter-nef-by-rating";
    platforms = lib.platforms.unix;
  };
}
