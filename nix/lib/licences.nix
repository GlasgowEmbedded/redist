{
  lib,
  runCommand,
}:

let
  extractLicence =
    drv:
    let
      name = lib.getName drv;
    in
    runCommand "extract-licence-${name}" { } (
      if lib.hasPrefix "qt6" name then
        ''
          # Qt generates a SBOM for us.
          cp -L -r ${drv}/sbom $out
        ''
      else
        ''
          if [[ -f ${drv.src} ]]; then
            mkdir source
            tar xf ${drv.src} -C source

            sourceRoot="${lib.optionalString (drv ? sourceRoot) "${drv.sourceRoot}"}"
            if [[ -z "$sourceRoot" ]]; then
              sourceRoot=$(ls ./source)
            fi

            SOURCES=$PWD/source/$sourceRoot
          else
            SOURCES=${drv.src}
          fi

          mkdir $out

          copied=0
          for prefix in COPYING LICENCE LICENSE LICENSE_1_0 license; do
            for file in $SOURCES/$prefix $SOURCES/$prefix.*; do
              if [[ -e $file ]]; then
                cp -L -r $file $out
                copied=$((copied + 1))
              fi
            done
          done

          if [[ $copied -eq 0 ]]; then
            echo Failed to find licence information for ${name}.
            echo Sources are located at ${drv.src}
            exit 1
          fi
        ''
    );

  extract =
    derivations:
    lib.lists.foldl (
      acc: drv:
      let
        name = lib.removeSuffix "-${drv.stdenv.targetPlatform.config}" "${lib.getName drv}";
        key = "${name}" + lib.optionalString (drv ? version) "-${drv.version}";
      in
      (
        if lib.isDerivation drv then

          {
            "${key}" = extractLicence drv;
          }
          // (extract drv.buildInputs)
          // (extract drv.propagatedBuildInputs)

        else
          { }
      )
      // acc
    ) { } derivations;
in
extract
