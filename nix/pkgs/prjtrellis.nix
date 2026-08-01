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
    rev = "56bb17047cd8b062f784de8666ceb3f90f77f77a";
    hash = "sha256-udsFVt8d1eJGdyDLMbDHqzq1ACFxyfw+FHvOk83Ke60=";
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
  ];

  enableParallelBuilding = true;
}
