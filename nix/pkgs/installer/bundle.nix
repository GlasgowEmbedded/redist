{
  runCommand,

  glasgow-installer-win32,
  glasgow-installer-win64,
}:

runCommand "bundle" { } ''
  mkdir $out

  cp ${glasgow-installer-win32}/GlasgowInterfaceExplorer.msi $out/GlasgowInterfaceExplorer-x86.msi
  cp ${glasgow-installer-win64}/GlasgowInterfaceExplorer.msi $out/GlasgowInterfaceExplorer-x64.msi
''
