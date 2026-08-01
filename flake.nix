{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            (final: prev: {
              glasgowPkgs = {
                api-ms-win-core-path = final.callPackage ./nix/pkgs/api-ms-win-core-path.nix { };
                libusb = final.callPackage ./nix/pkgs/libusb.nix { };
                python = final.callPackage ./nix/pkgs/python { };

                glasgow-dist = final.callPackage ./nix/pkgs/glasgow-dist.nix { };
              };
            })
          ];
        };

        win32Pkgs = pkgs.callPackage ./nix/cross/win32.nix { };
        win64Pkgs = pkgs.callPackage ./nix/cross/win64.nix { };
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages = {
          glasgow-dist-win32 = win32Pkgs.glasgowPkgs.glasgow-dist;
          glasgow-dist-win64 = win64Pkgs.glasgowPkgs.glasgow-dist;

          python = win32Pkgs.glasgowPkgs.python;
        };
      }
    );
}
