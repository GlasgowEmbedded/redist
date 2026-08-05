{
  buildPackages,
  callPackage,
  glasgowPkgs,
  lib,
  pkgs,
  stdenv,
  tcl,
  tk,
  windows,
}:

let
  pythonVersion = lib.versions.majorMinor glasgowPkgs.python.version;
  tclVersion = lib.versions.majorMinor tcl.version;
  tkVersion = lib.versions.majorMinor tk.version;
  glasgowSrc = callPackage ./glasgow/sources.nix { };

  inputs =
    with glasgowPkgs;
    [
      libusb

      python
      api-ms-win-core-path

      icestorm
      nextpnr
      prjtrellis
      yosys

      pxview
    ]
    ++ (with windows; [
      # Some MinGW bits.
      mcfgthreads
      mingw_w64
    ])
    ++ (with pkgs; [
      # Qt 6 Windows 7 patches. We don't use this directly so don't extract licence information for build inputs.
      (vlc.overrideAttrs (_: {
        buildInputs = [ ];
        propagatedBuildInputs = [ ];
      }))
    ]);
in
stdenv.mkDerivation {
  pname = "glasgow-dist";
  version = "2026-08-04";

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
    cp -r ${glasgowPkgs.prjtrellis}/share/trellis $out/share/

    cp -n ${glasgowPkgs.nextpnr}/bin/* $out/bin/

    cp ${glasgowPkgs.yosys}/bin/yosys.exe $out/bin/
    cp ${glasgowPkgs.yosys}/bin/yosys-abc.exe $out/bin/
    cp -n ${glasgowPkgs.yosys}/bin/*.dll $out/bin/
    cp -r ${glasgowPkgs.yosys}/share/yosys/ $out/share/

    # Glasgow manual. Copied from buildPackages since it's static.
    cp -r ${buildPackages.glasgowPkgs.manual} $out/doc/manual/

    # Glasgow examples.
    cp -r ${glasgowSrc}/examples $out/doc/examples/

    # Glasgow wheels.
    cp -r ${glasgowPkgs.wheels} $out/dist/
    chmod +w $out/dist/
    (cd $out/dist/; ls ./*.whl > requirements.txt)

    # PXView.
    cp -n ${glasgowPkgs.pxview}/bin/* $out/bin/
    cp -r ${glasgowPkgs.pxview}/share/PXView/ $out/share/
    cp -r ${pkgs.qt6}/plugins/* $out/bin/

    # PXView needs Qt6Svg, which isn't grabbed by default.
    cp -r ${pkgs.qt6}/bin/Qt6Svg.dll $out/bin/

    # Grab the bits of libsigrok that PXView leaves lying around in share.
    # We need to do this since we ship both PXView and PulseView and we don't want them to fight.
    chmod -R +w $out/share/PXView
    cp -r ${glasgowPkgs.pxview}/share/libsigrokdecode/decoders $out/share/PXView/
    cp ${glasgowPkgs.pxview}/share/sigrok-firmware/* $out/share/PXView/res/

    # Extract licences.
    mkdir $out/share/licences
    ${lib.foldlAttrs (
      acc: k: v:
      "cp -r ${v} $out/share/licences/${k}\n" + acc
    ) "" (glasgowPkgs.extract-licences inputs)}
  '';
}
