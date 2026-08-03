{
  fetchFromGitHub,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "CreateEmbedLangTransform";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "RISCSoftware";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-FYiaijdCdZ4pIbkeCpmCKJ34Wz5W3AjLJadobzvFDKs=";
  };

  patchPhase = ''
    cd ${pname}

    substituteInPlace main.cpp \
      --replace-fail MsiQuery.h msiquery.h \
      --replace-fail Windows.h windows.h
  '';

  buildPhase = ''
    $CXX main.cpp -o celt.exe -lmsi
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp celt.exe $out/bin/
  '';
}
