# Additional root certificates (e.g. a corporate proxy's), when the machine
# has an additional-trusts.crt.
{ config, ... }:
let
  inherit (config.machine) additionalTrusts;
in
{
  flake.modules.nixos.certificates =
    { lib, ... }:
    {
      security.pki.certificateFiles = lib.optional (additionalTrusts != null) additionalTrusts;
    };
}
