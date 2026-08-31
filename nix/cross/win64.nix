{
  pkgs,
  overlays ? [ ],
}:

import pkgs.path {
  inherit (pkgs.stdenv.hostPlatform) system;
  crossSystem = pkgs.lib.systems.examples.mingw-ucrt-x86_64 // {
    rust.rustcTargetSpec = "x86_64-win7-windows-gnu";
  };

  overlays = overlays ++ [
    (pkgs.callPackage ./win-overlay.nix { })
  ];
}
