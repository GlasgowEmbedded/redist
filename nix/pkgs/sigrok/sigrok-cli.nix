{
  autoreconfHook,
  fetchFromGitHub,
  glasgowPkgs,
  glib,
  pkg-config,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "sigrok-cli";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "sigrokproject";
    repo = "${pname}";
    rev = "f44dd91347e7ac797cefc23162b9fcf0b7329f1f";
    hash = "sha256-LJ+32XiQYfjMLYze/zICVKvqmhtyc85zvxAXXi2HIi0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib

    glasgowPkgs.libsigrok
    glasgowPkgs.libsigrokdecode
  ];
}
