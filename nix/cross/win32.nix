{
  pkgs,
  overlays ? [ ],
}:

import pkgs.path {
  inherit (pkgs.stdenv.hostPlatform) system;
  crossSystem = {
    config = "i686-w64-mingw32";
    libc = "ucrt";
  };

  overlays = overlays ++ [
    (pkgs.callPackage ./win-overlay.nix { })
  ];
}
