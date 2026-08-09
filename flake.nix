{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.whitequark.org/bin/"
    ];

    extra-trusted-public-keys = [
      "bin:80gf0YiO7eVPNP6nYSZSfK7zySg3PzU4xeCgWGNyxas="
    ];
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
              glasgowPkgs = final.lib.makeScope final.newScope (self: {
                api-ms-win-core-path = self.callPackage ./nix/pkgs/api-ms-win-core-path.nix { };
                libusb = self.callPackage ./nix/pkgs/libusb.nix { };
                python = self.callPackage ./nix/pkgs/python { };

                render = self.callPackage ./nix/lib/render.nix { };
                glasgow = self.callPackage ./nix/pkgs/glasgow { };
                manual = self.callPackage ./nix/pkgs/glasgow/manual.nix { };
                wheels = self.callPackage ./nix/pkgs/glasgow/wheels.nix { };

                icestorm = self.callPackage ./nix/pkgs/toolchain/icestorm.nix { };
                nextpnr = self.callPackage ./nix/pkgs/toolchain/nextpnr.nix { };
                prjtrellis = self.callPackage ./nix/pkgs/toolchain/prjtrellis.nix { };
                yosys = self.callPackage ./nix/pkgs/toolchain/yosys.nix { };

                libsigrok = self.callPackage ./nix/pkgs/sigrok/libsigrok.nix { };
                libsigrokdecode = self.callPackage ./nix/pkgs/sigrok/libsigrokdecode.nix { };
                pulseview = self.callPackage ./nix/pkgs/sigrok/pulseview.nix { };
                sigrok-cli = self.callPackage ./nix/pkgs/sigrok/sigrok-cli.nix { };

                pxview = self.callPackage ./nix/pkgs/pxview.nix { };

                celt = self.callPackage ./nix/pkgs/celt.nix { };

                installsword = self.callPackage ./nix/pkgs/installer/installsword.nix { };

                extract-licences = self.callPackage ./nix/lib/licences.nix { };
                glasgow-dist = self.callPackage ./nix/pkgs/glasgow-dist.nix { };
              });
            })
          ];
        };

        win32Pkgs = pkgs.callPackage ./nix/cross/win32.nix { };
        win64Pkgs = pkgs.callPackage ./nix/cross/win64.nix { };

        glasgow-installer-win32 = pkgs.callPackage ./nix/pkgs/installer {
          glasgow-arch = "x86";
          flake-rev = (self.shortRev or self.dirtyShortRev or "unknown");
          flake-revCount = (self.revCount or 9999);
          inherit (win32Pkgs.glasgowPkgs) glasgow-dist installsword;
          inherit (win64Pkgs.glasgowPkgs) celt;
        };

        glasgow-installer-win64 = pkgs.callPackage ./nix/pkgs/installer {
          glasgow-arch = "x64";
          flake-rev = (self.shortRev or self.dirtyShortRev or "unknown");
          flake-revCount = (self.revCount or 9999);
          inherit (win64Pkgs.glasgowPkgs) glasgow-dist installsword;
          inherit (win64Pkgs.glasgowPkgs) celt;
        };

        glasgow-installers = pkgs.callPackage ./nix/pkgs/installer/bundle.nix {
          inherit glasgow-installer-win32 glasgow-installer-win64;
        };

        website-dl = pkgs.callPackage ./nix/pkgs/website-dl.nix {
          inherit glasgow-installers;
        };
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages = {
          glasgow-dist-win32 = win32Pkgs.glasgowPkgs.glasgow-dist;
          glasgow-dist-win64 = win64Pkgs.glasgowPkgs.glasgow-dist;

          glasgow-pkgs-win32 = win32Pkgs.glasgowPkgs;
          glasgow-pkgs-win64 = win64Pkgs.glasgowPkgs;

          inherit
            glasgow-installer-win32
            glasgow-installer-win64
            glasgow-installers
            website-dl
            pkgs
            ;
        };
      }
    );
}
