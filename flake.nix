{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      discoverPackages =
        callPackage:
        let
          packagesDir = ./pkgs/by-name;
          prefixes = builtins.attrNames (builtins.readDir packagesDir);
          packagesFromPrefix =
            prefix:
            let
              prefixPath = packagesDir + "/${prefix}";
            in
            map (name: {
              inherit name;
              value = callPackage (prefixPath + "/${name}") { };
            }) (builtins.attrNames (builtins.readDir prefixPath));
        in
        builtins.listToAttrs (builtins.concatMap packagesFromPrefix prefixes);

      discoverPythonModules =
        let
          modulesDir = ./pkgs/development/python-modules;
          moduleNames = builtins.attrNames (builtins.readDir modulesDir);
        in
        pyfinal: pyprev:
        builtins.listToAttrs (
          map (name: {
            inherit name;
            value = pyprev.callPackage (modulesDir + "/${name}") { };
          }) moduleNames
        );

      overlays.default =
        final: prev:
        discoverPackages final.callPackage
        // {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ discoverPythonModules ];
        };

      flake = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [ "python3.13-pypdf2-3.0.1" ];
            };
            overlays = [ self.overlays.default ];
          };

        in
        {
          packages = discoverPackages pkgs.callPackage;
          formatter = pkgs.nixfmt-tree;
        }
      );
    in
    flake
    // {
      inherit overlays;
      nixosModules.default = {
        nixpkgs.overlays = [ self.overlays.default ];
        imports = [ ./modules ];
      };
    };
}
