{ lib, ... }:
let
  moduleFiles = builtins.filter (f: f != "default.nix" && lib.hasSuffix ".nix" f) (
    builtins.attrNames (builtins.readDir ./.)
  );
in
{
  imports = map (f: ./. + "/${f}") moduleFiles;
}
