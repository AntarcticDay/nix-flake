# modules/darwin/forgejo.nix
{ config, lib, pkgs, ... }:

let
  # ---- Settings you may tweak -------------------------------------------------
  user    = "stefano";                             # macOS user running Forgejo
  homeDir = "/Users/${user}";
  workDir = "${homeDir}/my/Forgejo";               # everything lives here
  logDir  = "${workDir}/log";
  dataDir = "${workDir}/data";
  sshDir  = "${workDir}/ssh";
  appIniPath = "${workDir}/app.ini";

  # Homebrew binary path (Intel vs Apple Silicon)
  programPath =
    if pkgs.stdenv.hostPlatform.system == "aarch64-darwin"
    then "/opt/homebrew/bin/forgejo"
    else "/usr/local/bin/forgejo";

  # Minimal bootstrap config copied on first activation only (writable by user).
  # The install wizard will overwrite/add secrets here.
  appIniBootstrap = pkgs.writeText "forgejo-bootstrap.ini" ''
    ; -----------------------------------------------------------------------------
    ; Forgejo bootstrap config (user-space, managed by nix-darwin on first run)
    ; This file is created ONLY if missing, then it is yours to edit.
    ; -----------------------------------------------------------------------------

    [paths]
    APP_DATA_PATH = ${dataDir}

    [server]
    PROTOCOL        = http
    HTTP_ADDR       = 127.0.0.1
    HTTP_PORT       = 3000
    DOMAIN          = localhost
    ROOT_URL        = http://localhost:3000/
    DISABLE_SSH     = false
    START_SSH_SERVER= true
    SSH_LISTEN_HOST = 127.0.0.1
    SSH_PORT        = 2222
    SSH_LISTEN_PORT = 2222
    SSH_DOMAIN      = localhost
    BUILTIN_SSH_SERVER_USER = ${user}
    SSH_ROOT_PATH   = ${sshDir}
    SSH_SERVER_HOST_KEYS = forgejo.ed25519, forgejo.rsa

    [database]
    DB_TYPE = sqlite3
    PATH    = ${dataDir}/forgejo.db

    [log]
    MODE      = file
    LEVEL     = info
    ROOT_PATH = ${logDir}

    [security]
    ; First run uses the install wizard (writable app.ini in your home).
    INSTALL_LOCK = false
  '';
in
{
  # --- Create user-space dirs/files BEFORE the daemon starts -------------------
  # We DO NOT manage /etc/forgejo/app.ini anymore.
  system.activationScripts.preActivation.text = lib.mkAfter ''
    set -eu
    umask 027

    /usr/bin/install -d -m 0750 -o ${user} -g staff ${workDir}
    /usr/bin/install -d -m 0750 -o ${user} -g staff ${dataDir}
    /usr/bin/install -d -m 0750 -o ${user} -g staff ${logDir}
    /usr/bin/install -d -m 0700 -o ${user} -g staff ${sshDir}

    # Create log files so launchd can open them on first start
    : > ${logDir}/forgejo.out.log
    : > ${logDir}/forgejo.err.log
    chown ${user}:staff ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log
    chmod 0640 ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log

    # First-run: create a writable app.ini only if missing
    if [ ! -f ${appIniPath} ]; then
      /bin/cp ${appIniBootstrap} ${appIniPath}
      chown ${user}:staff ${appIniPath}
      chmod 0640 ${appIniPath}
    fi

    # Generate SSH host keys if missing (ed25519 + rsa 4096)
    if [ ! -f ${sshDir}/forgejo.ed25519 ]; then
      /usr/bin/ssh-keygen -t ed25519 -f ${sshDir}/forgejo.ed25519 -N ""
      chown ${user}:staff ${sshDir}/forgejo.ed25519 ${sshDir}/forgejo.ed25519.pub
      chmod 0600 ${sshDir}/forgejo.ed25519
      chmod 0644 ${sshDir}/forgejo.ed25519.pub
    fi
    if [ ! -f ${sshDir}/forgejo.rsa ]; then
      /usr/bin/ssh-keygen -t rsa -b 4096 -f ${sshDir}/forgejo.rsa -N ""
      chown ${user}:staff ${sshDir}/forgejo.rsa ${sshDir}/forgejo.rsa.pub
      chmod 0600 ${sshDir}/forgejo.rsa
      chmod 0644 ${sshDir}/forgejo.rsa.pub
    fi
  '';

  # --- No /etc file anymore! ---------------------------------------------------
  # (Intentionally NOT setting environment.etc."forgejo/app.ini".)

  # --- LaunchDaemon (runs as your user, uses user-space paths) -----------------
  launchd.daemons.forgejo = {
    serviceConfig = {
      ProgramArguments = [
        "${programPath}"
        "web"                           # subcommand first
        "-c" "${appIniPath}"            # config lives in your home
        "-w" "${workDir}"               # work dir in your home
      ];
      EnvironmentVariables = {
        FORGEJO_WORK_DIR = workDir;
        PATH = "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin";
      };
      UserName         = "${user}";
      WorkingDirectory = "${workDir}";
      KeepAlive        = true;
      RunAtLoad        = true;
      StandardOutPath  = "${logDir}/forgejo.out.log";
      StandardErrorPath= "${logDir}/forgejo.err.log";
    };
  };
}
