{
  buildPackages,
  cmake,
  fetchzip,
  lib,
  python3,
  ninja,
  stdenv,
  writeText,
}:

let
  # Used for Qt 6.8.3.
  qtPkgs =
    import
      (fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/d27c0d08ef25912c134b755d40a1bd1d843bfb7c.tar.gz";
        sha256 = "sha256:070y6magaf3500s7fmp3s536bllzk56c0qbjhr8snsisgvjj98xj";
      })
      {
        inherit (buildPackages.stdenv.hostPlatform) system;
      };

  qtEnv =
    with qtPkgs.qt6;
    env "qt6" [
      qtbase
      qtshadertools
      qttools
    ];

  toolchain = writeText "toolchain.cmake" ''
    set(CMAKE_SYSTEM_NAME Windows)

    set(CMAKE_C_COMPILER   ${stdenv.cc.targetPrefix}gcc)
    set(CMAKE_CXX_COMPILER ${stdenv.cc.targetPrefix}g++)

    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  '';
in
stdenv.mkDerivation rec {
  pname = "qt6";
  version = "6.8.3";

  src = fetchzip {
    url = "https://download.qt.io/official_releases/qt/${lib.versions.majorMinor version}/${version}/single/qt-everywhere-src-${version}.tar.xz";
    hash = "sha256-zF71+iPjgNqy5og7dWP19K3xDSTXsCwLxwc39jw/Vi8=";
  };

  nativeBuildInputs = [
    cmake
    python3
    ninja
  ];

  patches = [
    ./0001-Patches-for-Windows-7-compatibility.patch
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_TOOLCHAIN_FILE" "${toolchain}")
    (lib.cmakeFeature "QT_HOST_PATH" "${qtEnv}")

    (lib.cmakeBool "BUILD_qtdeclarative" false)
    (lib.cmakeFeature "QT_BUILD_SUBMODULES" "qtbase;qtsvg;qtwebsockets")
  ];
}
