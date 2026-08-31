{
  cmake,
  fetchFromGitHub,
  glasgowPkgs,
  lib,
  ninja,
  pkgsBuildBuild,
  qt6,
  qtPkgs,
  stdenv,
}:

let
  pyVersion = (lib.versions.majorMinor glasgowPkgs.python.version);

  version = qt6.version;
  src = fetchFromGitHub {
    owner = "qtproject";
    repo = "pyside-pyside-setup";
    rev = "v${version}";
    hash = "sha256-8wGPdQHalX7WV0HKi+5dtTMrdtaNw1yFp/PJqeVsPmE=";
  };

  shiboken6-generator = pkgsBuildBuild.stdenv.mkDerivation rec {
    pname = "shiboken6-generator";
    inherit src version;
    sourceRoot = "${src.name}/sources/shiboken6";

    nativeBuildInputs = [
      cmake
      ninja
    ];

    buildInputs = with pkgsBuildBuild; [
      llvmPackages.libclang
      llvmPackages.libllvm
      python3
      qtPkgs.qt6.qtbase
    ];

    patches = [
      ./generator-cross-compiler.patch
      ./generator-additional-opts.patch
      ./use-clang-platform-typesystems.patch
    ];
    patchFlags = [ "-p3" ];

    cmakeFlags = [
      (lib.cmakeBool "SHIBOKEN_BUILD_TOOLS" true)
      (lib.cmakeBool "SHIBOKEN_BUILD_LIBS" false)
      (lib.cmakeBool "BUILD_TESTS" false)

      (lib.cmakeFeature "CROSS_CXX_COMPILER" "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}g++")
    ];

    dontWrapQtApps = true;
    enableParallelBuilding = true;

    __structuredAttrs = true;
  };
in
stdenv.mkDerivation {
  pname = "PySide6";
  inherit src version;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    glasgowPkgs.python
    qt6
  ];

  patches = [
    ./force-os-win.patch
  ];

  cmakeFlags = [
    (lib.cmakeFeature "QFP_PYTHON_HOST_PATH" "${pkgsBuildBuild.python3}/bin/python")
    (lib.cmakeFeature "QFP_SHIBOKEN_HOST_PATH" "${shiboken6-generator}")
    (lib.cmakeFeature "Python_SOABI" "cp${
      lib.replaceString "." "" pyVersion
    }-mingw_${stdenv.hostPlatform.uname.processor}_ucrt_gnu")
    (lib.cmakeBool "FORCE_LIMITED_API" false)
    (lib.cmakeBool "is_pyside6_superproject_build" true)
    (lib.cmakeFeature "SHIBOKEN_GENERATOR_EXTRA_FLAGS" "--platform=windows")
    (lib.cmakeFeature "SKIP_MODULES" "DBus")
  ];

  postPatch = ''
    # Use the correct path separator.
    for file in sources/pyside6/cmake/PySideSetup.cmake sources/shiboken6/cmake/ShibokenSetup.cmake; do
      substituteInPlace $file \
        --replace-fail 'set(PATH_SEP "\;")' 'set(PATH_SEP ":")'
    done

    # Fix broken shebang.
    substituteInPlace sources/shiboken6/cmake/ShibokenHelpers.cmake \
      --replace-fail '#!/bin/bash' '#!''${BASH}'

    # raise ValueError('ZIP does not support timestamps before 1980')
    find \
      sources/shiboken6/shibokenmodule/files.dir/shibokensupport/ \
      sources/shiboken6/libshiboken/embed/signature_bootstrap.py \
      -exec touch -d "1980-01-01T00:00Z" {} \;
  '';

  env = {
    NIX_CFLAGS_COMPILE = "-I${glasgowPkgs.python}/include/python${pyVersion}";

    SHIBOKEN_ADDITIONAL_COMPILER_OPTS = "-target ${stdenv.hostPlatform.uname.processor}-w64-mingw32 -Wno-everything";
  };

  enableParallelBuilding = true;
}
