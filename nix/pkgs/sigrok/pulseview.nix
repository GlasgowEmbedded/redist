{
  boost,
  cmake,
  fetchFromGitHub,
  glasgowPkgs,
  lib,
  ninja,
  pkg-config,
  qt6,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "pulseview";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "sigrokproject";
    repo = "${pname}";
    rev = "af02198741b4e57c9f9b796bd5e6c0f2ae9f2f2b";
    hash = "sha256-4K3sMCTlFnu8iiokMYc1O7jNVQ7vTtSiT2dCpLRC44s=";
  };

  patches = [
    ./pulseview-safer-mutex.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    qt6

    glasgowPkgs.libsigrok
    glasgowPkgs.libsigrokdecode
  ];

  cmakeFlags = [
    (lib.cmakeBool "STATIC_PKGDEPS_LIBS" stdenv.hostPlatform.isStatic)
  ];

  postPatch = lib.optionalString (!stdenv.hostPlatform.isStatic) ''
    sed -i \
      -e '/STATIC_PKGDEPS_LIBS TRUE/d' \
      -e '/QT_STATICPLUGIN/d' CMakeLists.txt
  '';

  enableParallelBuilding = true;
}
