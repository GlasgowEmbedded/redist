{
  autoconf-archive,
  autoreconfHook,
  buildPackages,
  fetchFromGitHub,
  libffi,
  ncurses,
  openssl,
  pkg-config,
  readline,
  stdenv,
  tcl,
  tk,
  zlib,
  zstd,
}:

stdenv.mkDerivation {
  pname = "Python";
  version = "3.14.6";

  src = fetchFromGitHub {
    owner = "msys2-contrib";
    repo = "cpython-mingw";
    rev = "5d7d5021e59614313678db107f47e9249329cf91";
    hash = "sha256-NLapeo01UKQzSJ+PDJfCPeLhjSj/zwRQUEAP6/55LLQ=";
  };

  patches = [
    ./windows-7-support.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs = [
    libffi
    ncurses
    openssl
    readline
    tcl
    tk
    zlib
    zstd
  ];

  configureFlags = [
    "--with-build-python=${buildPackages.python3}/bin/python"
    "--enable-shared"
    "--enable-optimizations"
  ];

  enableParallelBuilding = true;
}
