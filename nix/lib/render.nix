{
  buildPackages,
  fetchurl,
  lib,
  runCommand,
  stdenv,
}:

let
  fetchPylockUrl =
    { name, url, hashes }:
    fetchurl {
      inherit name url;
      inherit (hashes) sha256;
    };

  findGenericWheel =
    wheels:
    lib.findFirst (wheel:
      lib.hasSuffix "py3-none-any.whl" wheel.name
    ) null wheels;

  convertPackage =
    package:
    let
      wheel = findGenericWheel (package.wheels or []);
      sdist = package.sdist or null;
    in
    {
      inherit (package) name version;
    }
    // (if wheel != null then
      {
        format = "wheel";
        src = fetchPylockUrl wheel;
      }
    else if sdist != null then
      {
        format = "sdist";
        src = fetchPylockUrl package.sdist;
      }
    else
      abort "expected at least one of wheel or sdist");

  mkDerivations =
    filename: buildSource:
    let
      data = fromTOML (builtins.readFile filename);
      pkgs = lib.filter (package: package.name != "glasgow") data.packages;
      srcs = map convertPackage pkgs;
      drvs = map (source: buildSource.${source.format} source) srcs;
    in
    drvs;

  buildSdist =
    python: overlays: source:
    (stdenv.mkDerivation {
      pname = source.name;
      inherit (source) version src;

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

      strictDeps = true;
    }).overrideAttrs (overlays.${source.name} or (_: { }));

  mkWheels =
    {
      filename,
      python ? buildPackages.python3,
      overlays ? { },
    }:
    let
      drvs = mkDerivations filename {
        sdist = source: buildSdist python overlays source;
        wheel = source: source.src;
      };
    in
    runCommand "mk-wheels" { } ''
      mkdir $out

      ${lib.foldl (
        acc: drv:
        ''
          if [[ -f ${drv} ]]; then
            # Derivation downloaded from PyPI
            cp -n ${drv} $out/${drv.name}
          else
            # Derivation built via buildSdist
            cp -n ${drv}/*.whl $out/
          fi
        ''
        + acc
      ) "" drvs}
    '';
in
mkWheels
