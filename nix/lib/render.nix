{ fetchPypi, lib, ... }:

let
  # Convert the list of files into an attrset.
  rewriteFiles =
    files:
    let
      mapped = map (f: {
        name = f.file;
        value = f.hash;
      }) files;
    in
    lib.listToAttrs mapped;

  # Convert the list of packages into an attrset.
  rewritePackages =
    packages:
    let
      mapped = map (pkg: {
        name = pkg.name;
        value = {
          version = pkg.version;
          files = rewriteFiles pkg.files;
        };
      }) packages;
    in
    lib.listToAttrs mapped;

  findWheel =
    files:
    lib.foldlAttrs (
      acc: k: _:
      if acc != null then
        acc
      else if lib.hasSuffix "py3-none-any.whl" k then
        k
      else
        null
    ) null files;

  # Extract the wheel URL or the source tarball.
  extract =
    name: package:
    let
      inherit (package) version;

      pname = lib.replaceString "-" "_" name;
      sourceName = "${pname}-${version}.tar.gz";
      wheelName = findWheel package.files;

      # Perform additional extraction for if we found a wheel.
      prefix = "${pname}-${version}-";
      filename' = lib.removePrefix prefix wheelName;
      filename'' = lib.removeSuffix ".whl" filename';
      parsed = lib.splitString "-" filename'';

      dist = builtins.elemAt parsed 0;
      abi = builtins.elemAt parsed 1;
      platform = builtins.elemAt parsed 2;
    in
    if wheelName != null then
      {
        inherit
          pname
          version
          dist
          abi
          platform
          ;

        hash = package.files.${wheelName};
        format = "wheel";
        python = dist;
      }
    else
      {
        inherit pname version;

        hash = package.files.${sourceName};
        format = "setuptools";
      };

  mkDerivation =
    builder: pname: sources:
    if sources.format == "setuptools" then builder sources else fetchPypi sources;

  mkDerivations =
    filename: builder:
    let
      data = fromTOML (builtins.readFile filename);
      packages = rewritePackages data.package;
      sources = lib.mapAttrs extract packages;
      mkDerivation' = mkDerivation builder;
    in
    lib.mapAttrs mkDerivation' sources;
in
mkDerivations
