{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cbagentd;
in
{
  options.services.cbagentd = {
    enable = lib.mkEnableOption "cbagentd";
    package = lib.mkPackageOption pkgs "carbonblack" { };
    code = lib.mkOption {
      type = lib.types.str;
      description = ''
        The company code needed for carbon black operation.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cbagentd = {
      description = "Carbon Black Predictive Security Cloud Endpoint Agent.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Environment = [
          "OPENSSL_CONF=${cfg.package.unwrapped}/var/opt/carbonblack/psc/ssl/openssl.cnf"
          "OPENSSL_MODULES=${cfg.package.unwrapped}/opt/carbonblack/psc/lib"
        ];
        ExecStart = "${cfg.package}/bin/cbagentd ${cfg.code} --foreground --stdout";
        KillMode = "process";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 10;
        Umask = 77;
      };
    };
  };
}
