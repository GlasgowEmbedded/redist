{
  autoconf-archive,
  autoreconfHook,
  doxygen,
  fetchFromCodeberg,
  libiconvReal,
  libftdi1,
  gettext,
  glasgowPkgs,
  glib,
  glibmm,
  libzip,
  pkg-config,
  python3,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "libsigrok";
  version = "0.7.0";

  src = fetchFromCodeberg {
    owner = "GlasgowEmbedded";
    repo = "${pname}";
    rev = "574c72f0e0c4fe488e05dde32f5bd3b992a5c517";
    hash = "sha256-g7QX4e1gLj8z8QcUxcrB9hgdGS50u8ml1mwrddsh3JE=";
  };

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    doxygen
    pkg-config
    python3
  ];

  buildInputs = [
    libftdi1
    gettext
    glib
    libzip

    glasgowPkgs.libusb

    # libsigrok _needs_ to have static libiconv for some reason.
    # I cannot determine what the cause of this is, and I do not care anymore.
    (libiconvReal.override { enableStatic = true; })
  ];

  propagatedBuildInputs = [
    glibmm
  ];

  enableParallelBuilding = true;
}
