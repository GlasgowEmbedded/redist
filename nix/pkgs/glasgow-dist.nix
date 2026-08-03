{
  buildPackages,
  glasgowPkgs,
  lib,
  stdenv,
  tcl,
  tk,
}:

let
  pythonVersion = lib.versions.majorMinor glasgowPkgs.python.version;
  tclVersion = lib.versions.majorMinor tcl.version;
  tkVersion = lib.versions.majorMinor tk.version;
in
stdenv.mkDerivation {
  pname = "glasgow-dist";
  version = "2026-08-03";

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/{bin,doc,lib,share}

    # libusb.
    cp ${glasgowPkgs.libusb}/bin/* $out/bin/

    # Copy specific bits of Python that we need.
    cp -n ${glasgowPkgs.python}/bin/*.dll $out/bin/
    cp -n ${glasgowPkgs.python}/bin/*.exe $out/bin/

    cp -r ${glasgowPkgs.python}/lib/python${pythonVersion}/ $out/lib/

    # Remove Python tests (~150 MB)
    chmod -R +w $out/lib/python${pythonVersion}/
    rm -r $out/lib/python${pythonVersion}/test/

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

    # Grab Tcl/Tk components for Tkinter.
    cp -r ${tcl}/lib/tcl${tclVersion}/ $out/lib/
    cp -r ${tk}/lib/tk${tkVersion}/ $out/lib/

    # Executable aliasing.
    cp $out/bin/python{3,}.exe
    cp $out/bin/python{3w,w}.exe

    # Yosys toolchain.
    cp -n ${glasgowPkgs.icestorm}/bin/icepack.exe $out/bin/
    cp -n ${glasgowPkgs.icestorm}/bin/*.dll $out/bin/

    cp -n ${glasgowPkgs.prjtrellis}/bin/ecppack.exe $out/bin/
    cp -n ${glasgowPkgs.prjtrellis}/bin/*.dll $out/bin/

    cp -n ${glasgowPkgs.nextpnr}/bin/* $out/bin/

    cp ${glasgowPkgs.yosys}/bin/yosys.exe $out/bin/
    cp ${glasgowPkgs.yosys}/bin/yosys-abc.exe $out/bin/
    cp -r ${glasgowPkgs.yosys}/share/yosys/ $out/share/

    # Glasgow manual. Copied from buildPackages since it's static.
    cp -r ${buildPackages.glasgowPkgs.manual} $out/doc/manual/

    # Glasgow wheels.
    cp -r ${glasgowPkgs.wheels} $out/dist/
    chmod +w $out/dist/
    (cd $out/dist/; ls ./*.whl > requirements.txt)
  '';
}
