{
  glasgowPkgs,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "glasgow-dist";
  version = "2026-07-31";

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/{bin,lib}

    cp ${glasgowPkgs.api-ms-win-core-path}/bin/* $out/bin/
    cp ${glasgowPkgs.libusb}/bin/* $out/bin/

    # Copy specific bits of Python that we need.
    cp ${glasgowPkgs.python}/bin/*.dll $out/bin/
    cp ${glasgowPkgs.python}/bin/*.exe $out/bin/

    cp -r ${glasgowPkgs.python}/lib/python3.14/ $out/lib/

    # Grab the remaining dependencies.
    ${lib.foldl (acc: drv:
    let
      drv' = if drv ? bin then drv.bin else drv.out;
    in
      "cp ${drv'}/bin/*.dll $out/bin\n" + acc) "" glasgowPkgs.python.buildInputs}
  '';
}
