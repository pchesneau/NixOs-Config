# `nix fmt` formats every Nix file; `nix flake check` checks they are.
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;

      checks.formatting = pkgs.runCommand "check-formatting" { nativeBuildInputs = [ pkgs.nixfmt ]; } ''
        cd ${inputs.self}
        find . -name '*.nix' -exec nixfmt --check {} +
        touch $out
      '';
    };
}
