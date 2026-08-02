{
  callPackage,
  glasgowPkgs,
  runCommand,
}:

let
  glasgow-sources = callPackage ./sources.nix { };

  wheels = glasgowPkgs.render { filename = "${glasgow-sources}/software/pdm.dist.lock"; };
in
runCommand "wheels" { } ''
  mkdir $out

  # Glasgow.
  cp ${glasgowPkgs.glasgow}/*.whl $out

  # Glasgow dependencies.
  cp ${wheels}/*.whl $out
''
