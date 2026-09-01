{
  callPackage,
  fetchurl,
  glasgowPkgs,
  runCommand,
}:

let
  glasgow-sources = callPackage ./sources.nix { };

  wheels = glasgowPkgs.render { filename = "${glasgow-sources}/software/pdm.dist.lock"; };

  pip-filename = "pip-26.2.1-py3-none-any.whl";
  pip = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/p/pip/${pip-filename}";
    hash = "sha256-cROK3x9MqQDNt9KJwht0lDKfIzK22F8OHEIQjAOE7T4=";
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
