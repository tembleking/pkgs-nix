{
  lib,
  runCommand,
  fetchFromGitHub,
  poetry2nix,
  pypkgs-build-requirements ? {
    dictor = [ "setuptools" ];
  },
}:
let
  version = "1.38.24";

  src = fetchFromGitHub {
    owner = "demisto";
    repo = "demisto-sdk";
    rev = "bb4164a06bec3cbec01f458d6c95aff7cb4cb4b3";
    hash = "sha256-KEGl5BUb0sZaxGWhKmu/QGe1LcZcbSQaPNEVaLjt/ao=";
  };

  patchedLock = runCommand "patched-poetry-lock" { } ''
    sed '/ios_13_0/d' ${src}/poetry.lock > $out
  '';

  overrides = poetry2nix.defaultPoetryOverrides.extend (
    self: super:
    (builtins.mapAttrs (
      package: build-requirements:
      (builtins.getAttr package super).overridePythonAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (builtins.map (
            pkg: if builtins.isString pkg then builtins.getAttr pkg super else pkg
          ) build-requirements);
      })
    ) pypkgs-build-requirements)
    // {
      bcrypt = super.bcrypt.overridePythonAttrs (old: {
        nativeBuildInputs = builtins.filter (
          drv:
          !(builtins.elem (drv.name or "") [
            "cargo-setup-hook.sh"
            "cargoSetupHook"
          ])
        ) (old.nativeBuildInputs or [ ]);
        cargoDeps = null;
      });
    }
  );
in
poetry2nix.mkPoetryApplication {
  projectDir = src;
  poetrylock = patchedLock;
  inherit overrides;
  preferWheels = true;
  checkGroups = [ ];
  extras = [ ];
  pythonRelaxDeps = [ "setuptools" ];
  meta = {
    mainProgram = "demisto-sdk";
    license = lib.licenses.mit;
  };
}
