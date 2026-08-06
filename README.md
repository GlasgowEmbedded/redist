# Windows redistributable for Glasgow Interface Explorer

This repository integrates all of the parts necessary to create an MSI redistributable for [Glasgow Interface Explorer](https://glasgow-embedded.org). This includes:

* Cross-compiling every dependency with MinGW (separately for 32-bit and 64-bit Windows):
    * Python 3.14 (patched to run on Windows 7) with Tcl/Tk;
    * Yosys, icestorm, prjtrellis, and nextpnr (trimmed down to only the FPGAs used in Glasgow);
    * Qt 6.8.3 (patched to run on Windows 7);
    * PulseView and PXView;
    * libusb.
* Building the Glasgow manual;
* Collecting Python dependencies from the Glasgow lockfile;
* Building the final MSI installers using [WiX 7](https://www.firegiant.com/wixtoolset/);
* Combining MSI installers for each culture into one multilingual product.


## Building installers

Install the Nix package manager. Then run:

```console
$ nix build .#glasgow-installers -L
```

This command will build two copies of the MinGW toolchain and will take a very long time to complete the first time. The MSI files (for x86 and x64 platforms) are placed in the `./result` directory.


## Updating sources

There are multiple references which may need updating:

* `nix/pkgs/glasgow/sources.nix` contains the Glasgow repository reference;
* `nix/pkgs/glasgow/intersphinx/*` contains the Intersphinx object inventories:
    * `python.inv` retrieved from https://docs.python.org/3/objects.inv;
    * others may be added later.
* `nix/pkgs/nextpnr.nix` contains the nextpnr repository reference;
* other, less commonly updated ones also present under `nix/pkgs/`.


## License

[0-clause BSD](LICENSE-0BSD.txt).
