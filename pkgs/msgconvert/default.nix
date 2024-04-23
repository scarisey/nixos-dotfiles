{
  fetchurl,
  perlPackages,
  lib,
  ...
}: let
in
  perlPackages.buildPerlModule {
    pname = "msgconvert";
    version = "0.921";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MV/MVZ/Email-Outlook-Message-0.921.tar.gz";
      hash = "sha256-+0q+6hTNpRweYLwhHPlSG7uq50uEEYym1Y8KciNoA4g=";
    };
    propagatedBuildInputs = with perlPackages; [EmailAddress EmailMIME EmailSender IOAll IOString OLEStorage_Lite];
    preCheck = "rm t/internals.t t/plain_jpeg_attached.t"; # these tests expect EmailMIME version 1.946 and fail with 1.949 (the output difference in benign)
    meta = {
      homepage = "https://www.matijs.net/software/msgconv/";
      description = "A .MSG to mbox converter";
      license = with lib.licenses; [artistic1 gpl1Plus];
      mainProgram = "msgconvert";
    };
  }
