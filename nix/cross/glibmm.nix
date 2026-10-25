{
  glib,
  glibmm_2_4,
  libsigcxx_2_0,
  meson,
  ninja,
  pkg-config,
  stdenv,
  windows,
}:

stdenv.mkDerivation {
  inherit (glibmm_2_4) pname version src;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [
    glib
    libsigcxx_2_0
    windows.pthreads
  ];

  enableParallelBuilding = true;
}
