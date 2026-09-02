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
    rev = "c97c2448ff574b0cbd0f6afc6f50143a92bbe35f";
    hash = "sha256-OyK0iuEGME/ySHUNVVu+/2IQIl4cAgv7qWS9bkMOTbQ=";
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
