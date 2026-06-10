{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.autofirma;
in
{
  options.programs.autofirma = {
    enable = lib.mkEnableOption "AutoFirma";
    package = lib.mkPackageOption pkgs "autofirma" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    xdg.mime = {
      enable = true;
      defaultApplications."x-scheme-handler/afirma" = "afirma.desktop";
    };
  };
}
