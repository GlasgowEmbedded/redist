{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    yosys = {
      url = "git+https://github.com/YosysHQ/Yosys?ref=main&rev=41a4b5a039d1f6e04d9c577d3f186ba85f6f1f01";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      yosys,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            (final: prev: {
              glasgowPkgs = final.lib.makeScope final.newScope (self: {
                api-ms-win-core-path = self.callPackage ./nix/pkgs/api-ms-win-core-path.nix { };
                libusb = self.callPackage ./nix/pkgs/libusb.nix { };
                python = self.callPackage ./nix/pkgs/python { };

                icestorm = self.callPackage ./nix/pkgs/icestorm.nix { };
                nextpnr = self.callPackage ./nix/pkgs/nextpnr.nix { };
                prjtrellis = self.callPackage ./nix/pkgs/prjtrellis.nix { };

                glasgow-dist = self.callPackage ./nix/pkgs/glasgow-dist.nix { };
              });
            })
          ];
        };

        win32Pkgs = pkgs.callPackage ./nix/cross/win32.nix {
          yosys = yosys.packages.${system}.yosys-win32;
        };
        win64Pkgs = pkgs.callPackage ./nix/cross/win64.nix {
          yosys = yosys.packages.${system}.yosys-win64;
        };
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages = {
          glasgow-dist-win32 = win32Pkgs.glasgowPkgs.glasgow-dist;
          glasgow-dist-win64 = win64Pkgs.glasgowPkgs.glasgow-dist;

          glasgow-pkgs-win32 = win32Pkgs.glasgowPkgs;
          glasgow-pkgs-win64 = win64Pkgs.glasgowPkgs;
        };
      }
    );
}
