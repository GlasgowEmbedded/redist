{
  autoreconfHook,
  buildPackages,
  fetchFromGitHub,
  glasgowPkgs,
  glib,
  pkg-config,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "libsigrokdecode";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "sigrokproject";
    repo = "${pname}";
    rev = "71f451443029322d57376214c330b518efd84f88";
    hash = "sha256-aW0llB/rziJxLW3OZU1VhxeM3MDWsaMVVgvDKZzdiIY=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib

    glasgowPkgs.python
  ];

  env = {
    PYTHON3 = "${buildPackages.python3}/bin/python3";
  };
}
