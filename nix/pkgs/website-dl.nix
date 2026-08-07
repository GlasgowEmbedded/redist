{
  glasgowPkgs,
  runCommand,

  glasgow-installers,
}:

runCommand "website-dl" { } ''
  mkdir -p $out/

  cp ${glasgowPkgs.glasgow}/*.whl $out/glasgow-0.1.dev0-py3-none-any.whl
  cp ${glasgow-installers}/*.msi $out/
''
