{
  pkgs,
  overlays ? [ ],
  yosys,
}:

import pkgs.path {
  inherit (pkgs.stdenv.hostPlatform) system;
  crossSystem = pkgs.lib.systems.examples.mingw-msvcrt-i686;

  overlays = overlays ++ [
    (pkgs.callPackage ./win-overlay.nix { inherit yosys; })
  ];
}
