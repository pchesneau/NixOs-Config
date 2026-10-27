{ inputs, ... }:
{
  # Declares `flake.modules.<class>.<name>`.
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];
}
