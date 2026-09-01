{
  pkgs,
  overlays ? [ ],
}:

let
  pkgs' = pkgs.applyPatches {
    src = pkgs.path;

    patches = [
      ../patches/0001-Use-DW2-EH-when-targeting-i686-MinGW.patch
    ];
  };
in
import pkgs' {
  inherit (pkgs.stdenv.hostPlatform) system;
  crossSystem = {
    config = "i686-w64-mingw32";
    libc = "ucrt";

    rust.rustcTargetSpec = "i686-win7-windows-gnu";
  };

  overlays = overlays ++ [
    (pkgs.callPackage ./win-overlay.nix { })
  ];
}
