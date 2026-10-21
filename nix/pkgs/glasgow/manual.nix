{
  buildPackages,
  callPackage,
  glasgowPkgs,
  python3,
  stdenvNoCC,
}:

let
  src = callPackage ./sources.nix { };

  wheels = glasgowPkgs.render {
    filename = "${src}/docs/manual/pylock.dist.toml";

    overlays = {
      pyccobs = finalAttrs: prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs ++ (with buildPackages; [
          cmake
          ninja
        ]);

        dontUseCmakeConfigure = true;
      };
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "glasgow-manual";
  version = "git";

  inherit src;
  sourceRoot = "${src.name}/docs/manual";

  nativeBuildInputs = [
    python3
  ];

  buildPhase = ''
    python -m venv .venv
    source .venv/bin/activate

    for f in ${wheels}/*.whl ${glasgowPkgs.wheels}/*.whl; do
      # Skip native dependencies that might've been built as part of the Glasgow wheels.
      if [[ "$f" =~ (mingw) ]]; then
        continue
      fi

      python -m pip install --no-cache-dir --no-deps $f
    done

    export HOME=$TMP
    export INTERSPHINX_PYTHON="${./intersphinx/python.inv}"
    export DOCS_IS_PRODUCTION=1

    for lang in en zh; do
      DOCS_LANGUAGE=$lang sphinx-build src $out/$lang -b html
    done
  '';
}
