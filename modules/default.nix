{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleFiles = builtins.filter (f: f != "default.nix" && lib.hasSuffix ".nix" f) (
    builtins.attrNames (builtins.readDir ./.)
  );

  importModule =
    file:
    let
      mod = import (./. + "/${file}");
      args = builtins.functionArgs mod;
      isNixosModule = args ? config || args ? lib || args ? pkgs || args ? options;
    in
    if isNixosModule then mod else mod (builtins.mapAttrs (name: _: pkgs.${name}) args);
in
{
  imports = map importModule moduleFiles;
}
