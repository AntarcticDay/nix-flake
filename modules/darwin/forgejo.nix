
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

    [paths]
    ; Where Forgejo stores app data (attachments, lfs, etc.)
    APP_DATA_PATH = ${dataDir}/data

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

    ; Store SSH host keys under ${dataDir}/ssh (not in ~/.ssh)
    SSH_ROOT_PATH = ${dataDir}/ssh
    ; List of host key files (relative to SSH_ROOT_PATH). If absent, Forgejo creates them.
    SSH_SERVER_HOST_KEYS = forgejo.ed25519, forgejo.rsa

    [database]
    DB_TYPE = sqlite3
    PATH    = ${dbPath}

    [log]
    MODE      = file
    LEVEL     = info
    ROOT_PATH = ${logDir}

    [security]
    ; Set to false for first-time install, then change to true and rebuild.
    INSTALL_LOCK = true
  '';
in
{
  # --- Create data/log/ssh dirs and log files BEFORE launchd starts the daemon
  # Also pre-generate SSH host keys if they don't exist (ed25519 + rsa 4096).
  system.activationScripts.preActivation.text = lib.mkAfter ''
    set -eu
    umask 027

    # Base dirs with correct ownership/permissions
    /usr/bin/install -d -m 0750 -o ${user} -g staff ${dataDir}
    /usr/bin/install -d -m 0750 -o ${user} -g staff ${dataDir}/data
    /usr/bin/install -d -m 0750 -o ${user} -g staff ${logDir}
    /usr/bin/install -d -m 0700 -o ${user} -g staff ${dataDir}/ssh

    # Ensure log files exist so launchd can open them on first start
    : > ${logDir}/forgejo.out.log
    : > ${logDir}/forgejo.err.log
    chown ${user}:staff ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log
    chmod 0640 ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log

    # Pre-generate SSH host keys if missing (so the built-in SSH can start)
    if [ ! -f ${dataDir}/ssh/forgejo.ed25519 ]; then
      /usr/bin/ssh-keygen -t ed25519 -f ${dataDir}/ssh/forgejo.ed25519 -N ""
      chown ${user}:staff ${dataDir}/ssh/forgejo.ed25519 ${dataDir}/ssh/forgejo.ed25519.pub
      chmod 0600 ${dataDir}/ssh/forgejo.ed25519
      chmod 0644 ${dataDir}/ssh/forgejo.ed25519.pub
    fi
    if [ ! -f ${dataDir}/ssh/forgejo.rsa ]; then
      /usr/bin/ssh-keygen -t rsa -b 4096 -f ${dataDir}/ssh/forgejo.rsa -N ""
      chown ${user}:staff ${dataDir}/ssh/forgejo.rsa ${dataDir}/ssh/forgejo.rsa.pub
      chmod 0600 ${dataDir}/ssh/forgejo.rsa
      chmod 0644 ${dataDir}/ssh/forgejo.rsa.pub
    fi
  '';

  # Write /etc/forgejo/app.ini with the minimal config
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
