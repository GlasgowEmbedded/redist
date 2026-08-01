{ lib, yosys }:

final: prev: {
  eigen = prev.eigen.overrideAttrs (oldAttrs: {
    meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
  });

  libconfuse = prev.libconfuse.overrideAttrs (oldAttrs: {
    meta.platforms = oldAttrs.meta.platforms ++ lib.platforms.windows;
  });

  glasgowPkgs = prev.glasgowPkgs.overrideScope (
    _: _: {
      yosys = yosys.overrideAttrs (oldAttrs: {
        cmakeFlags = oldAttrs.cmakeFlags ++ [
          (lib.cmakeBool "YOSYS_WITHOUT_SLANG" true)
        ];
      });
    }
  );
}
