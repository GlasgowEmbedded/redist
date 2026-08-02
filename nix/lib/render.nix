{
  buildPackages,
  fetchPypi,
  lib,
  runCommand,
  stdenv,
  stdenvNoCC,
}:

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
          files = if pkg ? files then rewriteFiles pkg.files else null;
        };
      }) packages;
    in
    lib.listToAttrs mapped;

  find =
    suffix: files:
    lib.foldlAttrs (
      acc: k: _:
      if acc != null then
        acc
      else if lib.hasSuffix suffix k then
        k
      else
        null
    ) null files;

  findTarball = find ".tar.gz";
  findWheel = find "py3-none-any.whl";

  # Extract the wheel URL or the source tarball.
  extract =
    name: package:
    let
      inherit (package) version;

      sourceName = findTarball package.files;
      wheelName = findWheel package.files;

      # Extract the source components.
      # Unfortunately, there is no standard enforced upon naming source tarballs.
      # This has led to everyone doing their own godforsaken naming scheme, so the nicest solution I've found is to
      # work backwards and construct the tail of the source tarball, only to use it to lop off the head and carry
      # it around like a fucking trophy. Kill me.
      sourceTail = "-${version}.tar.gz";

      # Extract the wheel components.
      parsedWheel = lib.splitString "-" (lib.removeSuffix ".whl" wheelName);
    in
    if wheelName != null then
      rec {
        pname = builtins.elemAt parsedWheel 0;
        version = builtins.elemAt parsedWheel 1;
        dist = builtins.elemAt parsedWheel 2;
        abi = builtins.elemAt parsedWheel 3;
        platform = builtins.elemAt parsedWheel 4;

        hash = package.files.${wheelName};
        format = "wheel";
        python = dist;
      }
    else
      {
        inherit version;
        pname = lib.removeSuffix sourceTail sourceName;

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
      packages' = lib.filterAttrs (_: v: v.files != null) packages;
      sources = lib.mapAttrs extract packages';
      mkDerivation' = mkDerivation builder;
    in
    lib.mapAttrs mkDerivation' sources;

  buildPythonPackage' =
    python: hasCC: sources:
    (if hasCC then stdenv.mkDerivation else stdenvNoCC.mkDerivation) {
      inherit (sources) pname version;

      src = fetchPypi sources;

      nativeBuildInputs = [
        (python.withPackages (
          ps: with ps; [
            pip
            setuptools
          ]
        ))
      ];

      buildPhase = ''
        python -m pip wheel --no-build-isolation --no-deps . --wheel-dir $out
      '';

      installPhase = ''
        # no-op
      '';
    };

  mkWheels =
    {
      filename,
      python ? buildPackages.python3,
      hasCC ? false,
    }:
    let
      drvs = mkDerivations filename (buildPythonPackage' python hasCC);
    in
    runCommand "mk-wheels" { } ''
      mkdir $out

      ${lib.foldlAttrs (
        acc: _: drv:
        ''
          if [[ -f ${drv} ]]; then
            # Derivation built via fetchPypi
            cp -n ${drv} $out/${drv.name}
          else
            # Derivation built via buildPythonPackage'
            cp -n ${drv}/*.whl $out/
          fi
        ''
        + acc
      ) "" drvs}
    '';
in
mkWheels
