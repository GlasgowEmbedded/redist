{
  fetchurl,
  pkg-config,
  tcl,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "tk";
  inherit (tcl) version;

  src = fetchurl {
    url = "mirror://sourceforge/tcl/tk${version}-src.tar.gz";
    hash = "sha256-lc1SioD15L21V6+bFKcZfWhgeTo4lOJefJ+tLtBdTDw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    tcl
  ];

  preConfigure = ''
    cd win
  '';

  configureFlags = [
    "--with-tcl=${tcl}/lib"
  ];

  enableParallelBuilding = true;
}
