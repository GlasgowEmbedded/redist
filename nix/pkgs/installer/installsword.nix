{
  stdenv,
}:

stdenv.mkDerivation {
  pname = "installsword";
  version = "1";

  src = ../../../wix/sword;

  installPhase = ''
    mkdir -p $out/bin/

    cp InstallSword.exe $out/bin/
  '';
}
