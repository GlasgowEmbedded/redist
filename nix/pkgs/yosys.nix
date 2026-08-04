{
  bison,
  cmake,
  fetchFromGitHub,
  flex,
  lib,
  libffi,
  pkg-config,
  python3,
  readline,
  ninja,
  stdenv,
  windows,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "yosys";
  version = "0.67";

  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "${pname}";
    rev = "d5f1795249138cf7d4f065a4dfaf2a095b33ec76";
    hash = "sha256-BYeZ30T004Lj3YOsSSj/pYsytRBwNlyRBtTO43HhVwA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    bison
    cmake
    flex
    pkg-config
    python3
    ninja
  ];

  buildInputs = [
    libffi
    readline
    windows.pthreads
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "YOSYS_SKIP_ABC_SUBMODULE_CHECK" true)
    (lib.cmakeBool "YOSYS_WITHOUT_SLANG" true)

    (lib.cmakeFeature "YOSYS_CHECKOUT_INFO" "${builtins.substring 0 7 src.rev}")
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Yosys Open SYnthesis Suite";
    homepage = "https://yosyshq.net/yosys/";
    license = licenses.isc;
  };
}
