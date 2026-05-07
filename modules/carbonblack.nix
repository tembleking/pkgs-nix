{ carbonblack }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption mkIf;
  cfg = config.services.cbagentd;
in
{
  options.services.cbagentd = {
    enable = mkEnableOption "cbagentd";
    code = mkOption {
      type = lib.types.str;
      description = ''
        The company code needed for carbon black operation.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cbagentd = {
      description = "Carbon Black Predictive Security Cloud Endpoint Agent.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Environment = [
          "OPENSSL_CONF=${carbonblack.unwrapped}/var/opt/carbonblack/psc/ssl/openssl.cnf"
          "OPENSSL_MODULES=${carbonblack.unwrapped}/opt/carbonblack/psc/lib"
        ];
        ExecStart = "${carbonblack}/bin/cbagentd ${cfg.code} --foreground --stdout";
        KillMode = "process";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 10;
        Umask = 77;
      };
    };
  };
}
