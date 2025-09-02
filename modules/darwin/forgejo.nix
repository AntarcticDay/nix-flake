# modules/darwin/forgejo.nix
{ config, lib, pkgs, ... }:

let
  # ---- Settings you may tweak -------------------------------------------------
  user    = "stefano";              # macOS user running Forgejo
  dataDir = "/var/lib/forgejo";     # persistent data directory
  logDir  = "${dataDir}/log";
  dbPath  = "${dataDir}/data/forgejo.db";

  # --- Secrets (temporary inline; later move to agenix/sops) -------------------
  # Generate fresh 64-hex strings with:  openssl rand -hex 32
  internalToken = "08e91b0cefba94d3982c9720bc25a1869f4390dbb62ddb847258d2466a071a98";     # openssl rand -hex 32   # INTERNAL_TOKEN
  secretKey     = "11a71f3607f9fcbd4ac32f011366504c538ee3cd28a2639637eb89b500abc3e2";     # openssl rand -hex 32   # SECRET_KEY
  jwtSecret     = "9228ff9c9a399b4461b160135f09d15f62b354767271b2d57ab97a6f071fa1c0";     # openssl rand -hex 32   # JWT_SECRET

  # Homebrew binary path (Intel vs Apple Silicon)
  programPath =
    if pkgs.stdenv.hostPlatform.system == "aarch64-darwin"
    then "/opt/homebrew/bin/forgejo"
    else "/usr/local/bin/forgejo";

  # ---- app.ini (managed by nix-darwin) ----------------------------------------
  appIni = ''
    ; -----------------------------------------------------------------------------
    ; Forgejo minimal config for macOS (managed by nix-darwin)
    ; Docs: https://forgejo.org/docs/latest/admin/config-cheat-sheet/
    ; -----------------------------------------------------------------------------

    [paths]
    APP_DATA_PATH = ${dataDir}/data

    [server]
    ; --- HTTP listen ------------------------------------------------------------
    PROTOCOL   = http
    HTTP_ADDR  = 127.0.0.1
    HTTP_PORT  = 3000
    DOMAIN     = localhost
    ROOT_URL   = http://localhost:3000/

    ; --- Built-in SSH server ----------------------------------------------------
    DISABLE_SSH = false
    START_SSH_SERVER = true
    SSH_LISTEN_HOST = 127.0.0.1
    SSH_PORT = 2222
    SSH_LISTEN_PORT = 2222
    SSH_DOMAIN = localhost
    BUILTIN_SSH_SERVER_USER = stefano
    SSH_ROOT_PATH = ${dataDir}/ssh
    SSH_SERVER_HOST_KEYS = forgejo.ed25519, forgejo.rsa

    [database]
    DB_TYPE = sqlite3
    PATH    = ${dbPath}

    [log]
    MODE      = file
    LEVEL     = info
    ROOT_PATH = ${logDir}

    [oauth2]
    JWT_SECRET = ${jwtSecret}

    [security]
    INSTALL_LOCK   = true
    INTERNAL_TOKEN = ${internalToken}
    SECRET_KEY     = ${secretKey}
  '';
in
{
  # --- Create data/log/ssh dirs and log files BEFORE launchd starts the daemon
  # Also pre-generate SSH host keys if they don't exist (ed25519 + rsa 4096).
  system.activationScripts.preActivation.text = lib.mkAfter ''
    set -eu
    umask 027

    /usr/bin/install -d -m 0750 -o ${user} -g staff ${dataDir}
    /usr/bin/install -d -m 0750 -o ${user} -g staff ${dataDir}/data
    /usr/bin/install -d -m 0750 -o ${user} -g staff ${logDir}
    /usr/bin/install -d -m 0700 -o ${user} -g staff ${dataDir}/ssh

    : > ${logDir}/forgejo.out.log
    : > ${logDir}/forgejo.err.log
    chown ${user}:staff ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log
    chmod 0640 ${logDir}/forgejo.out.log ${logDir}/forgejo.err.log

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

  # Write /etc/forgejo/app.ini (distribution-style path)
  environment.etc."forgejo/app.ini".text = appIni;

  # LaunchDaemon: Forgejo web
  launchd.daemons.forgejo = {
    serviceConfig = {
      ProgramArguments = [
        "${programPath}"
        "web"
        "-c" "/etc/forgejo/app.ini"
        "-w" "${dataDir}"
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
