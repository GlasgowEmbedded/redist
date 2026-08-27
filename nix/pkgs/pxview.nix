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
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "PXLogic";
    repo = "${pname}";
    rev = "${pname}_v${version}";
    hash = "sha256-mmIXwanilBoxNaOmfSpnlyf9nbSYYrNxWriPnqw1VNo=";
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
    substituteInPlace PXView/pv/mainwindow/submainframe.cpp \
      --replace-fail {W,w}indows.h

    substituteInPlace PXView/pv/platform/winnativewidget.h \
      --replace-fail {W,w}indows.h \
      --replace-fail {W,w}indowsx.h
  '';

  cmakeFlags = [
    (lib.cmakeFeature "Python3_EXECUTABLE" "${buildPackages.python3}/bin/python")

    # Some extra flags for mimalloc.
    (lib.cmakeBool "MI_OVERRIDE" false)
    (lib.cmakeFeature "MI_EXTRA_CPPDEFS" "MI_USE_RTLGENRANDOM=1")
  ];

  enableParallelBuilding = true;

    __structuredAttrs = true;
}
