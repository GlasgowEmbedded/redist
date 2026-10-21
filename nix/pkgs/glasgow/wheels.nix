{
  callPackage,
  fetchurl,
  glasgowPkgs,
  runCommand,
}:

let
  glasgow-sources = callPackage ./sources.nix { };

  wheels = glasgowPkgs.render { filename = "${glasgow-sources}/software/pylock.dist.toml"; };

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
