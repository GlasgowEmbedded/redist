{
  boost,
  bzip2,
  buildPackages,
  cmake,
  eigen,
  fetchFromGitHub,
  glasgowPkgs,
  lib,
  ninja,
  python3,
  stdenv,
  xz,
  zlib,
  zstd,
}:

let
  version = "0.11";
  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "nextpnr";
    rev = "nextpnr-${version}";
    hash = "sha256-mCB/myasr3+esrN4xg+GCU7k/C+SSy4opVl+lmm4nH4=";
  };

  bba = buildPackages.stdenv.mkDerivation {
    pname = "nextpnr-bba";
    inherit src version;

    nativeBuildInputs = [
      cmake
      ninja
    ];

    buildInputs = [
      buildPackages.boost
    ];

    cmakeDir = "../bba";

    installPhase = ''
      mkdir -p $out/{bin,lib/cmake}

      install -Dm755 bbasm $out/bin/

      cat >$out/lib/cmake/bbasm.cmake <<EOF
      add_executable(bbasm IMPORTED)

      set_target_properties(bbasm PROPERTIES
        IMPORTED_LOCATION "${placeholder "out"}/bin/bbasm")
      EOF
    '';
  };
in
stdenv.mkDerivation {
  pname = "nextpnr";
  inherit src version;

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    boost
    eigen

    # Boost dependencies that aren't propagated correctly.
    bzip2
    xz
    zlib
    zstd
  ];

  cmakeFlags = [
    (lib.cmakeFeature "ARCH" "ice40;ecp5")
    (lib.cmakeBool "BUILD_PYTHON" false)
    (lib.cmakeBool "USE_IPO" false)

    (lib.cmakeFeature "ECP5_DEVICES" "25k")
    (lib.cmakeFeature "ICE40_DEVICES" "8k")

    (lib.cmakeFeature "ICESTORM_INSTALL_PREFIX" glasgowPkgs.icestorm.outPath)
    (lib.cmakeFeature "TRELLIS_INSTALL_PREFIX" buildPackages.glasgowPkgs.prjtrellis.outPath)
    (lib.cmakeFeature "TRELLIS_LIBDIR" "${buildPackages.glasgowPkgs.prjtrellis}/lib/trellis")

    (lib.cmakeFeature "BBA_IMPORT" "${bba}/lib/cmake/bbasm.cmake")

    (lib.cmakeFeature "CURRENT_GIT_VERSION" "nextpnr-${version}-9999-g${builtins.substring 0 7 src.rev}")
  ];

  enableParallelBuilding = true;
}
