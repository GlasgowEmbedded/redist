{
  callPackage,
  glasgowPkgs,
  python313,
  stdenvNoCC,
}:

let
  src = callPackage ./sources.nix { };

  wheels = glasgowPkgs.render {
    filename = "${src}/docs/manual/pdm.dist.lock";
    python = python313;
    hasCC = true;
  };
in
stdenvNoCC.mkDerivation {
  pname = "glasgow-manual";
  version = "git";

  inherit src;
  sourceRoot = "${src.name}/docs/manual";

  nativeBuildInputs = [
    python313
  ];

  buildPhase = ''
    python -m venv .venv
    source .venv/bin/activate

    for f in ${wheels}/*.whl ${glasgowPkgs.wheels}/*.whl; do
      python -m pip install --no-deps $f
    done

    export HOME=$TMP
    export INTERSPHINX_PYTHON="${./intersphinx/objects.inv}"

    for lang in en zh; do
      DOCS_LANGUAGE=$lang sphinx-build src $out/build-$lang -b html
    done
  '';
}
