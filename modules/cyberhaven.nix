{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cyberhaven;
in
{
  options.services.cyberhaven = {
    enable = lib.mkEnableOption "cyberhaven";
    package = lib.mkPackageOption pkgs "cyberhaven" { };
    backend = lib.mkOption {
      type = lib.types.str;
      description = "Backend URL";
      default = "https://c2f.cyberhaven.io";
    };
    installToken = lib.mkOption {
      type = lib.types.str;
      description = "The install token for cyberhaven";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cyberhaven = {
      description = "Cyberhaven";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = "${cfg.package}/bin/cyberhaven '${cfg.backend}' '${cfg.installToken}'";
        KillMode = "process";
        KillSignal = "SIGKILL";
      };
    };
  };
}
