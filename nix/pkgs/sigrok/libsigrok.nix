{
  autoconf-archive,
  autoreconfHook,
  doxygen,
  fetchFromGitHub,
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
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "sigrokproject";
    repo = "${pname}";
    rev = "0bc2487778e660f4d3116729b6f4aee2b1996bb0";
    hash = "sha256-j79Wx5FFFKptcwtIjQ0Cvtzl46lnow6bExpMNzI8KlM=";
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
