{
  dotnetPackages,
  fetchurl,
  lib,
  runCommand,
}:

let
  fetchNuGet =
    {
      pname,
      version,
      hash ? lib.fakeHash,
    }:
    fetchurl {
      url = "https://www.nuget.org/api/v2/package/${pname}/${version}";
      inherit hash;
    };

  version = "7.0.0";

  wix = fetchNuGet {
    pname = "wix";
    inherit version;
    hash = "sha256-f5kuV8NW3L2i6pYb87NI4b19Mdlnlb5Kw5HgTPFAU20=";
  };

  wix-sdk = fetchNuGet {
    pname = "WixToolset.Sdk";
    inherit version;
    hash = "sha256-r49y+yVQ6cLPALbq9ePtgRUUqis/NE36NCVArzlnaXk=";
  };

  wix-util = fetchNuGet {
    pname = "WixToolset.Util.wixext";
    inherit version;
    hash = "sha256-ZDHviW3a/wjSEiHmfemKNZf6lPsFVzcsuW/rTtrgwj4=";
  };

  wix-ui = fetchNuGet {
    pname = "WixToolset.UI.wixext";
    inherit version;
    hash = "sha256-FxbCy+1GE6cpG1d1Ywz00Nyll1aLoRKM7F/aGQPwW9E=";
  };
in
runCommand "mk-wix-nuget" { nativeBuildInputs = [ dotnetPackages.Nuget ]; } ''
  export HOME=$TMP

  cp ${wix} wix-${version}.nupkg
  cp ${wix-sdk} WixToolset.Sdk-${version}.nupkg
  cp ${wix-util} WixToolset.Util.wixext-${version}.nupkg
  cp ${wix-ui} WixToolset.UI.wixext-${version}.nupkg

  for pkg in *.nupkg; do
    nuget add $pkg -source $out
  done
''
