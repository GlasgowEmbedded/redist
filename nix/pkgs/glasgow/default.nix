{
  buildPackages,
  callPackage,
  stdenvNoCC,
}:

let
  src = callPackage ./sources.nix { };
  version = "0.1";
in
stdenvNoCC.mkDerivation {
  pname = "glasgow";

  inherit src version;

  nativeBuildInputs = [
    (buildPackages.python3.withPackages (
      ps: with ps; [
        pdm-backend
        pip
      ]
    ))
  ];

  buildPhase = ''
    export PDM_BUILD_SCM_VERSION="${version}.dev0+g${builtins.substring 0 7 src.rev}"
    python -m pip wheel --no-build-isolation --no-deps ./software --wheel-dir $out
  '';
}
