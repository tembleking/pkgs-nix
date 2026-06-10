{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.configurador-fnmt;
in
{
  options.programs.configurador-fnmt = {
    enable = lib.mkEnableOption "Configurador FNMT";
    package = lib.mkPackageOption pkgs "configurador-fnmt" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    xdg.mime = {
      enable = true;
      defaultApplications."x-scheme-handler/fnmtcr" = "configuradorfnmt.desktop";
    };
  };
}
