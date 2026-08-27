{
  boost,
  buildPackages,
  cmake,
  fetchFromGitHub,
  fftw,
  glasgowPkgs,
  glib,
  lib,
  libftdi1,
  libzip,
  nettle,
  ninja,
  nlohmann_json,
  pcre2,
  pkg-config,
  qt6,
  stdenv,
  windows,
}:

stdenv.mkDerivation rec {
  pname = "PXView";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "PXLogic";
    repo = "${pname}";
    rev = "${pname}_v${version}";
    hash = "sha256-H6SIhrf/B6L6MHGKBBd3JaPoPJ41h/Kxhl7iOVmet9A=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    fftw
    glib
    libftdi1
    libzip
    nettle
    nlohmann_json
    pcre2
    qt6

    glasgowPkgs.python

    windows.pthreads
  ];

  patchPhase = ''
    # GuiPrivate isn't a separate module on Qt 6.8.3.
    substituteInPlace CMake/deps.cmake \
      --replace-fail " GuiPrivate " " "

    # Fix headers.
    substituteInPlace PXView/pv/submainframe.cpp \
      --replace-fail {W,w}indows.h

    substituteInPlace PXView/pv/winnativewidget.h \
      --replace-fail {W,w}indows.h \
      --replace-fail {W,w}indowsx.h
  '';

  cmakeFlags = [
    (lib.cmakeFeature "Python3_EXECUTABLE" "${buildPackages.python3}/bin/python")
  ];

  enableParallelBuilding = true;
}
