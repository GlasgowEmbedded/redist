{ lib }:

final: prev: {
  eigen = prev.eigen.overrideAttrs (oldAttrs: {
    meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
  });

  fftw = (prev.fftw.override { gfortran = null; }).overrideAttrs (
    oldAttrs:
    lib.optionalAttrs final.stdenv.hostPlatform.isMinGW {
      configureFlags = [
        "--enable-threads"
      ];

      meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
    }
  );

  # Required for libsigrok.
  gettext = prev.gettext.overrideAttrs (
    oldAttrs:
    lib.optionalAttrs final.stdenv.hostPlatform.isMinGW {
      configureFlags = oldAttrs.configureFlags ++ [ "--enable-static" ];
    }
  );

  glib =
    if final.stdenv.hostPlatform.isMinGW then
      prev.glib.override {
        withIntrospection = false;
      }
    else
      prev.glib;

  glibmm = final.callPackage ./glibmm.nix { };

  libconfuse = prev.libconfuse.overrideAttrs (oldAttrs: {
    meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
  });

  libftdi1 =
    if final.stdenv.hostPlatform.isMinGW then final.callPackage ./ftdi.nix { } else prev.libftdi1;

  libzip = prev.libzip.overrideAttrs (oldAttrs: {
    meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
  });

  qt6 = if final.stdenv.hostPlatform.isMinGW then final.callPackage ./qt6 { } else prev.qt6;

  tcl = if final.stdenv.hostPlatform.isMinGW then final.callPackage ./tcl.nix { } else prev.tcl;

  tk = if final.stdenv.hostPlatform.isMinGW then final.callPackage ./tk.nix { } else prev.tk;
}
