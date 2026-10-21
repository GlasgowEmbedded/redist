{
  buildPackages,
  callPackage,
  fetchpatch2,
  fetchurl,
  glasgowPkgs,
  stdenv,
  runCommand,
}:

let
  glasgow-sources = callPackage ./sources.nix { };

  wheels = glasgowPkgs.render {
    filename = "${glasgow-sources}/software/pylock.dist.toml";

    overlays = {
      pyccobs = finalAttrs: prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs ++ (with buildPackages; [
          cmake
          ninja
        ]);

        patches = [
          (fetchpatch2 {
            url = "https://github.com/flumf/pyccobs/commit/c874e71df436017571b62834fc034e0c4646c5bf.patch";
            hash = "sha256-D1QVTW/yy99fpmJ1D7OdzT32unN753recWztOouiUbU=";
          })
        ];

        postConfigure = ''
          export CMAKE_ARGS=$cmakeFlags
          export CMAKE_GENERATOR=Ninja
        '';

        buildPhase = ''
          python setup.py bdist_wheel --dist-dir=$out \
            --plat-name=mingw-${stdenv.hostPlatform.uname.processor}-ucrt-gnu
        '';

        dontUseCmakeConfigure = true;
      };
    };
  };

  pip-filename = "pip-26.2.2-py3-none-any.whl";
  pip = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/p/pip/${pip-filename}";
    hash = "sha256-/X9N+oGQ4BQBO58I8+lz9OTCb/0XmiBIlVM6clSBOnA=";
  };
in
runCommand "wheels" { } ''
  mkdir $out

  # Glasgow.
  cp ${glasgowPkgs.glasgow}/*.whl $out

  # Glasgow dependencies.
  cp ${wheels}/*.whl $out

  # Newer version of pip.
  cp ${pip} $out/${pip-filename}
''
