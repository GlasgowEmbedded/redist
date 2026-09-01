{
  autoreconfHook,
  fetchFromGitHub,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "libusb";
  version = "1.0.30";

  src = fetchFromGitHub {
    owner = "libusb";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-qgs8h1vSqJg2muBDWN5nJlvaMjGYZnwMg1m07rqzHco=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--enable-windows-hotplug"
  ];

  dontAddDisableDepTrack = true;

  enableParallelBuilding = true;
}
