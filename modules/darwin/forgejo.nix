
# modules/darwin/forgejo.nix
{ config, lib, pkgs, ... }:

let
  # ---- Settings you may tweak -------------------------------------------------
  user    = "stefano";              # macOS user running Forgejo
  dataDir = "/var/lib/forgejo";     # persistent data directory
  logDir  = "${dataDir}/log";
  dbPath  = "${dataDir}/data/forgejo.db";

  # Homebrew binary path (Intel vs Apple Silicon)
  programPath =
    if pkgs.stdenv.hostPlatform.system == "aarch64-darwin"
    then "/opt/homebrew/bin/forgejo"
    else "/usr/local/bin/forgejo";

  # ---- app.ini minimal config -------------------------------------------------
  appIni = ''
    ; -----------------------------------------------------------------------------
    ; Forgejo minimal config for macOS (managed by nix-darwin)
    ; Docs: https://forgejo.org/docs/latest/admin/config-cheat-sheet/
    ; -----------------------------------------------------------------------------

    [server]
    PROTOCOL   = http
    HTTP_ADDR  = 127.0.0.1
    HTTP_PORT  = 3000
    DOMAIN     = localhost
    ROOT_URL   = http://localhost:3000/
    DISABLE_SSH = true  ; set false if you want the built-in SSH (pick a non-22 port on macOS)

    [server]
    DISABLE_SSH = false
    START_SSH_SERVER = true     ; enable the built-in SSH server
    SSH_LISTEN_HOST = 127.0.0.1 ; o 0.0.0.0 per LAN
    SSH_PORT = 2222             ; shown in clone URLs
    SSH_LISTEN_PORT = 2222      ; actual listen port
    SSH_DOMAIN = localhost      ; used in displayed SSH URLs

    [database]
    DB_TYPE = sqlite3
    PATH    = ${dbPath}

    [log]
    MODE      = file
    LEVEL     = info
    ROOT_PATH = ${logDir}

    [security]
    INSTALL_LOCK = true  ; will be set to true after the web installer

  '';
in
{
  # Create data/log folders and set ownership/permissions
  system.activationScripts.forgejo = lib.mkAfter ''
    mkdir -p ${dataDir}/data ${logDir}
    chown -R ${user}:staff ${dataDir}
    chmod -R 750 ${dataDir}
  '';

  # Write /etc/forgejo/app.ini with the minimal config
  environment.etc."forgejo/app.ini".text = appIni;

  # LaunchDaemon: run Forgejo at boot, as non-root user, with explicit work-path/config
  launchd.daemons.forgejo = {
    serviceConfig = {
      ProgramArguments = [
        "${programPath}"
        "-w" "${dataDir}"            # explicit work path (data dir)
        "-c" "/etc/forgejo/app.ini"  # explicit config path
        "web"                        # start the web server
      ];
      EnvironmentVariables = { FORGEJO_WORK_DIR = dataDir; };
      UserName         = "${user}";
      WorkingDirectory = "${dataDir}";
      KeepAlive        = true;
      RunAtLoad        = true;
      StandardOutPath  = "${logDir}/forgejo.out.log";
      StandardErrorPath= "${logDir}/forgejo.err.log";
    };
  };
}
