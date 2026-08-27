# Here be dragons.

{
  callPackage,
  celt,
  fetchzip,
  glasgowPkgs,
  glibcLocales,
  installsword,
  python3,
  runCommand,
  wine64,

  glasgow-arch,
  glasgow-dist,
  glasgow-type ? "Release",
  flake-rev,
  flake-revCount,
}:

let
  wixPkgs = callPackage ./wix.nix { };

  dotnet-sdk = fetchzip {
    url = "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.302/dotnet-sdk-10.0.302-win-x64.zip";
    hash = "sha256-Nj+sI86MZVB7JjoY09UHXAG9OlKMYxgytVSfjhAaw48=";
    stripRoot = false;
  };
in
runCommand "build-installer"
  {
    nativeBuildInputs = [
      glibcLocales
      python3
      wine64
    ];
  }
  ''
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export FONTCONFIG_FILE=$PWD/fc.conf
    export GLASGOW_GIT_HASH=${builtins.substring 0 7 glasgowPkgs.glasgow.src.rev}
    export GLASGOW_VERSION=${glasgowPkgs.glasgow.version}
    export HOME=$TMP
    export LANG=en_US.UTF-8
    export PRODUCT_GIT_HASH=${flake-rev}
    export PRODUCT_VERSION=${toString flake-revCount}
    export PXVIEW_VERSION=${glasgowPkgs.pxview.version}
    export PYTHON_VERSION=${glasgowPkgs.python.version}
    export PULSEVIEW_VERSION=${glasgowPkgs.pulseview.version}
    export WINEDEBUG=-all
    export ZADIG_VERSION=2.9

    # Make Fontconfig happy to reduce noise.
    cat >fc.conf <<EOF
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
    </fontconfig>
    EOF

    # Required to properly display output from wine in the nix build.
    run_wine() {
      wine "$@" 2>&1 | tr '\r\n' '\n'
    }

    wineboot

    # Set up NuGet. Remove the old source since otherwise ours gets ignored due to signature issues.
    cp -r ${wixPkgs} $HOME/.wine/drive_c/pkgs
    run_wine ${dotnet-sdk}/dotnet.exe nuget remove source nuget.org
    run_wine ${dotnet-sdk}/dotnet.exe nuget add source 'C:\pkgs' --name Local

    cp -r ${../../../wix}/ wix/
    chmod -R +w wix/
    cd wix/

    # Build the retro background effect.
    cp -n ${installsword}/bin/* sword/

    # Install DLLs for wine.
    cp tools/*.dll $HOME/.wine/drive_c/windows/system32/
    wine reg add "HKCU\Software\Wine\DllOverrides" /v cabinet /t REG_SZ /d "native,builtin"
    wine reg add "HKCU\Software\Wine\DllOverrides" /v msi /t REG_SZ /d "native,builtin"

    # Workaround MSI claiming files are missing. I don't understand this behaviour, but this seems to fix it.
    cp -r ${glasgow-dist} src/
    chmod -R +w src/

    python tools/dir2wxs.py -dir src -wxs InstallApp.wxs -component-group InstallApp
    run_wine ${dotnet-sdk}/dotnet.exe build -p:Platform=${glasgow-arch} -p:Configuration=${glasgow-type}

    # Merge MSIs.
    run_wine ${celt}/bin/celt.exe bin/${glasgow-arch}/${glasgow-type}/{en-US,zh-CN}/GlasgowInterfaceExplorer.msi

    # Deploy final artefacts.
    cp -r bin/${glasgow-arch}/${glasgow-type}/en-US/ $out
  ''
