{ lib, yosys }:

final: prev: {
  eigen = prev.eigen.overrideAttrs (oldAttrs: {
    meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
  });

  libconfuse = prev.libconfuse.overrideAttrs (oldAttrs: {
    meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
  });

  tcl = if final.stdenv.hostPlatform.isMinGW then final.callPackage ./tcl.nix { } else prev.tcl;

  tk = if final.stdenv.hostPlatform.isMinGW then final.callPackage ./tk.nix { } else prev.tk;

  glasgowPkgs = prev.glasgowPkgs.overrideScope (
    _: _: {
      yosys = yosys.overrideAttrs (oldAttrs: {
        cmakeFlags = oldAttrs.cmakeFlags ++ [
          (lib.cmakeBool "YOSYS_WITHOUT_SLANG" true)
          (lib.cmakeBool "YOSYS_WITHOUT_TCL" true)
        ];
      });
    }
  );
}
