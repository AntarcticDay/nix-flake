
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
    ; --- HTTP listen ------------------------------------------------------------
    PROTOCOL   = http
    HTTP_ADDR  = 127.0.0.1
    HTTP_PORT  = 3000
    DOMAIN     = localhost
    ROOT_URL   = http://localhost:3000/

    ; --- Built-in SSH server (recommended for local use) ------------------------
    DISABLE_SSH = false
    START_SSH_SERVER = true
    SSH_LISTEN_HOST = 127.0.0.1       ; use 0.0.0.0 to expose on LAN
    SSH_PORT = 2222                   ; shown in clone URLs
    SSH_LISTEN_PORT = 2222            ; actual listen port
    SSH_DOMAIN = localhost            ; used in displayed SSH URLs
    BUILTIN_SSH_SERVER_USER = stefano

    [database]
    DB_TYPE = sqlite3
    PATH    = ${dbPath}

    [log]
    MODE      = file
    LEVEL     = info
    ROOT_PATH = ${logDir}

    [security]
    ; Set to false for first-time install, then change to true and rebuild.
    INSTALL_LOCK = false
  '';
in
{
  # Create data/log dirs and empty log files *before* launchd starts the daemon
  system.activationScripts.forgejo = lib.mkBefore ''
    # Directories with correct ownership/permissions
    install -d -m 0750 -o ${user} -g staff ${dataDir}
    install -d -m 0750 -o ${user} -g staff ${dataDir}/data
    install -d -m 0750 -o ${user} -g staff ${logDir}

    # Ensure log files exist so launchd can open them
    : > ${logDir}/forgejo.out.log
    : > ${logDir}/forgejo.err.log
    chown ${user}:staff ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log
    chmod 0640 ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log
  '';

  # Write /etc/forgejo/app.ini with the minimal config (distribution-style path)
  environment.etc."forgejo/app.ini".text = appIni;

  # LaunchDaemon: run Forgejo at boot, as non-root user, with explicit work-path/config
  launchd.daemons.forgejo = {
    serviceConfig = {
      ProgramArguments = [
        "${programPath}"
        "web"                       # start the web server (subcommand first)
        "-c" "/etc/forgejo/app.ini" # explicit config path
        "-w" "${dataDir}"           # explicit work path (data dir)
      ];
      EnvironmentVariables = {
        FORGEJO_WORK_DIR = dataDir;
        PATH = "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin";
      };
      UserName         = "${user}";
      WorkingDirectory = "${dataDir}";
      KeepAlive        = true;
      RunAtLoad        = true;
      StandardOutPath  = "${logDir}/forgejo.out.log";
      StandardErrorPath= "${logDir}/forgejo.err.log";
    };
  };
}
