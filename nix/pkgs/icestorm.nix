{
  fetchFromGitHub,
  pkg-config,
  python3,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "icestorm";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-SLSxqgVsYMUxv8YjY1iRLnVFiIAhk/GKmZr4Ido0A3o=";
  };

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  makeFlags = [
    "EXE=.exe"
    "ICEPROG=0"
    "PREFIX=${placeholder "out"}"
  ];

  enableParallelBuilding = true;
}
