{
  boost,
  cmake,
  fetchFromGitHub,
  lib,
  ninja,
  python3,
  stdenv,
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;
in
stdenv.mkDerivation rec {
  pname = "prjtrellis";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "${pname}";
    rev = "eb47bd6e9cf2365d11ef10df3128f956f4fb8550";
    hash = "sha256-pRqURk9jmRWB6qZuKHzryNRn98vbZy5RCHt5ID6VXXc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    boost
  ];

  cmakeDir = "../libtrellis";
  cmakeFlags = [
    (lib.cmakeBool "BUILD_PYTHON" (!isCross))
    (lib.cmakeFeature "CURRENT_GIT_VERSION" "${builtins.substring 0 7 src.rev}")

    (lib.cmakeFeature "CMAKE_INSTALL_DATADIR" "${placeholder "out"}/share")
  ];

  enableParallelBuilding = true;
}
