{
  stdenv,
}:

stdenv.mkDerivation {
  pname = "combase-shim";
  version = "1";

  src = ./.;

  buildPhase = ''
    # windows-rs doesn't support Windows 7 anymore, due to imports from combase instead of ole32.
    $CC shim.def -o combase.dll -shared
  '';

  installPhase = ''
    mkdir -p $out/bin/
    cp combase.dll $out/bin/
  '';
}
