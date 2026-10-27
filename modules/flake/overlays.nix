# Packages are distributed through overlays: each feature contributes
# `overlays.<name>`, and `overlays.default` composes them all (an overlay
# cannot be merged from several files). The host applies it.
{ config, lib, ... }:
{
  flake.overlays.default = lib.composeManyExtensions (
    lib.attrValues (removeAttrs config.flake.overlays [ "default" ])
  );
}
