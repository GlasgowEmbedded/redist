{
  buildPackages,
  glib,
  libsigcxx,
  meson,
  ninja,
  pkg-config,
  stdenv,
  windows,
}:

stdenv.mkDerivation {
  inherit (buildPackages.glibmm) pname version src;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [
    glib
    libsigcxx
    windows.pthreads
  ];

  enableParallelBuilding = true;
}
