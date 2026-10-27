# azure-cli, with fabric on invoke 2: fabric is marked broken on invoke 3
# (https://github.com/fabric/fabric/issues/2376), which breaks azure-cli.
# Its Python set gets invoke 2, as upstream pins (invoke==2.2.0); paramiko
# needs the same invoke, so it is the whole set and not just fabric.
# azure-cli builds that set with `python3.override { packageOverrides = … }`,
# which replaces any `packageOverrides` given from outside, so ours is chained
# into that call. Every other package keeps invoke 3. Drop once fabric is
# fixed.
{
  flake.overlays.azure-cli = final: prev: {
    azure-cli = prev.azure-cli.override {
      python3 = prev.python3 // {
        override =
          args:
          prev.python3.override (
            args
            // {
              packageOverrides = final.lib.composeExtensions (pyfinal: pyprev: {
                invoke = pyprev.invoke.overridePythonAttrs {
                  version = "2.2.1";
                  src = final.fetchPypi {
                    pname = "invoke";
                    version = "2.2.1";
                    hash = "sha256-UVv0m0pIkyt5sCRZA0jaIvOcSULf+ZGtH7i4uuob5wc=";
                  };
                };
              }) (args.packageOverrides or (_: _: { }));
            }
          );
      };
    };
  };
}
