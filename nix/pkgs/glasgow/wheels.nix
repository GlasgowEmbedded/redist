{
  buildPackages,
  callPackage,
  fetchPypi,
  glasgowPkgs,
  stdenvNoCC,
}:

let
  glasgow-sources = callPackage ./sources.nix { };

  buildPythonPackage =
    sources:
    stdenvNoCC.mkDerivation {
      inherit (sources) pname version;

      src = fetchPypi sources;

      nativeBuildInputs = [
        (buildPackages.python3.withPackages (ps: with ps; [
          setuptools
        ]))
      ];

      buildPhase = ''
        # We only really need to build MarkupSafe, which can be built without the native component.
        python setup.py bdist_wheel
      '';

      installPhase = ''
        mkdir $out
        cp -r dist/*.whl $out/
      '';
    };

  wheels = glasgowPkgs.render "${glasgow-sources}/software/pdm.dist.lock" buildPythonPackage;
in
{
  pkgs = wheels;
}
