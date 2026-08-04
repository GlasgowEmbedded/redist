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

let
  libusb' = fetchFromGitHub {
    owner = "haikumuse";
    repo = "libusb";
    rev = "ab8525e12fd9639adcb6d57c3156ca5f97ae5186";
    hash = "sha256-7DxZNwlRUT/cYQXunOgWaHDXVPu1DjyESjxQcG8eBOY=";
  };
in
stdenv.mkDerivation rec {
  pname = "PXView";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "PXLogic";
    repo = "${pname}";
    rev = "${pname}_v${version}";
    hash = "sha256-37DQ9XC63F54uY1f/m9FJPvhESyFvS9rQXA3unid6Mw=";
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
    # Temporary workaround for the libusb submodule being broken.
    rm -r libusb
    cp -r ${libusb'} libusb
    chmod -R +w libusb

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
