{
  pkgs,
  overlays ? [ ],
}:

import pkgs.path {
  inherit (pkgs.stdenv.hostPlatform) system;
  crossSystem = pkgs.lib.systems.examples.mingw-ucrt-x86_64;

  overlays = overlays ++ [
    (pkgs.callPackage ./win-overlay.nix { })
  ];
}
