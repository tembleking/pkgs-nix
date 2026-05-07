{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      poetry2nix,
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

      overlays.default = final: prev: discoverPackages final.callPackage;

      flake = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };

          # demisto-sdk needs poetry2nix, which requires a pinned nixpkgs
          pkgs-poetry2nix = import poetry2nix.inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ poetry2nix.overlays.default ];
          };
        in
        {
          packages = discoverPackages pkgs.callPackage // {
            demisto-sdk = pkgs-poetry2nix.callPackage ./pkgs/by-name/de/demisto-sdk { };
          };
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
