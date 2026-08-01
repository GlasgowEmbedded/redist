{
  glasgowPkgs,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "glasgow-dist";
  version = "2026-08-01";

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/{bin,lib,share}

    # libusb.
    cp ${glasgowPkgs.libusb}/bin/* $out/bin/

    # Copy specific bits of Python that we need.
    cp -n ${glasgowPkgs.python}/bin/*.dll $out/bin/
    cp -n ${glasgowPkgs.python}/bin/*.exe $out/bin/

    cp -r ${glasgowPkgs.python}/lib/python3.14/ $out/lib/

    # Grab the remaining Python dependencies.
    cp -n ${glasgowPkgs.api-ms-win-core-path}/bin/* $out/bin/
    ${lib.foldl (
      acc: drv:
      let
        drv' =
          if drv ? bin then
            drv.bin
          # ncurses stores binaries in -dev (???)
          else if drv ? dev && (builtins.pathExists "${drv.dev}/bin") then
            drv.dev
          else
            drv.out;
      in
      "cp -n ${drv'}/bin/*.dll $out/bin\n" + acc
    ) "" glasgowPkgs.python.buildInputs}

    # Yosys toolchain.
    cp -n ${glasgowPkgs.icestorm}/bin/icepack.exe $out/bin/
    cp -n ${glasgowPkgs.icestorm}/bin/*.dll $out/bin/

    cp -n ${glasgowPkgs.prjtrellis}/bin/ecppack.exe $out/bin/
    cp -n ${glasgowPkgs.prjtrellis}/bin/*.dll $out/bin/

    cp -n ${glasgowPkgs.nextpnr}/bin/* $out/bin/

    cp ${glasgowPkgs.yosys}/bin/yosys.exe $out/bin/
    cp ${glasgowPkgs.yosys}/bin/yosys-abc.exe $out/bin/
    cp -r ${glasgowPkgs.yosys}/share/yosys/ $out/share/
  '';
}
