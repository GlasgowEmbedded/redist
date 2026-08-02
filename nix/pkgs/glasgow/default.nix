{
  buildPackages,
  callPackage,
  stdenvNoCC,
}:

let
  src = callPackage ./sources.nix { };
in
stdenvNoCC.mkDerivation {
  pname = "glasgow";
  version = "git";

  inherit src;

  nativeBuildInputs = [
    (buildPackages.python3.withPackages (
      ps: with ps; [
        pdm-backend
        pip
      ]
    ))
  ];

  buildPhase = ''
    export PDM_BUILD_SCM_VERSION="0.1.dev0+${builtins.substring 0 7 src.rev}"
    python -m pip wheel --no-build-isolation --no-deps ./software --wheel-dir $out
  '';
}
