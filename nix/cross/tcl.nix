{
  buildPackages,
  fetchurl,
  lib,
  stdenv,
}:

let
  version = "8.6.18";
  libver = lib.replaceString "." "" (lib.versions.majorMinor version);
in
stdenv.mkDerivation {
  pname = "tcl";
  inherit version;

  src = fetchurl {
    url = "mirror://sourceforge/tcl/tcl${version}-src.tar.gz";
    hash = "sha256-FPmvMrF2f/cYR3qPl0rQPDQ0EJfmtD9M5UZE7pdOJo4=";
  };

  preConfigure = ''
    cd win
  '';

  makeFlags = [
    "TCL_EXE=${lib.getExe' buildPackages.tcl "tclsh"}"
  ];

  # We only care for a subset of Tcl, this improves build times.
  buildFlags = [
    "binaries"
    "doc"
  ];

  installTargets = [
    "install-binaries"
    "install-headers"
    "install-libraries"
    "install-private-headers"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p $out/lib/pkgconfig

    cat >$out/lib/pkgconfig/tcl.pc <<EOF
    # tcl pkg-config source file

    prefix=$out
    exec_prefix=$out
    libdir=$out/lib
    includedir=\''${prefix}/include
    libfile=libtcl${libver}.a

    Name: Tool Command Language
    Description: Tcl is a powerful, easy-to-learn dynamic programming language, suitable for a wide range of uses.
    URL: https://www.tcl-lang.org/
    Version: ${version}
    Libs: -L\''${libdir} -ltcl${libver}
    Libs.private: -luserenv -lws2_32 -lnetapi32
    Cflags: -I\''${includedir}
    EOF
  '';
}
