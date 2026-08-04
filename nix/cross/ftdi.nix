{
  cmake,
  fetchFromCodeberg,
  glasgowPkgs,
  lib,
  ninja,
  pkg-config,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "libftdi1";
  version = "1.5";

  src = fetchFromCodeberg {
    owner = "YoWASP";
    repo = "libftdi";
    rev = "de9f01ece34d2fe6e842e0250a38f4b16eda2429";
    hash = "sha256-U37M5P7itTF1262oW+txbKxcw2lhYHAwy1ML51SDVMs=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [
    glasgowPkgs.libusb
  ];

  cmakeFlags = [
    (lib.cmakeBool "FTDI_EEPROM" false)
  ];
}
