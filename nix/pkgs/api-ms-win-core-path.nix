{
  fetchFromGitHub,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "api-ms-win-core-path";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "adang1345";
    repo = "${pname}";
    rev = "fc05a4ce6093fd6355755f70911c0dc203d554c7";
    hash = "sha256-EH32ttbKpPcgTUs6O2+Gi6r6cr3oYUzAFoO/tB2Xdy0=";
  };

  patchPhase = ''
    for file in path.c pathcch.h; do
      substituteInPlace $file --replace-fail Windows.h windows.h
    done
  '';

  buildPhase = ''
    $CC -shared -o api-ms-win-core-path-l1-1-0.dll path.c api-ms-win-core-path.def
  '';

  installPhase = ''
    mkdir -p $out/bin/

    cp api-ms-win-core-path-l1-1-0.dll $out/bin/
  '';
}
