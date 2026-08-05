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
  version = "0.68";

  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-cf3L3Il717ReAcPTPNHZLwldDeCwuPqHYoxeQusBOOg=";
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
