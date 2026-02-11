#!/system/bin/sh

# ==============================================================================
# Sets LSPosed module scope for multiple Niatic Games on boot and when triggering the Action Button.
# ==============================================================================

# --- PATH SETUP ---
SCRIPT_DIR=${0%/*}
MODDIR=$(dirname "$SCRIPT_DIR")
SQLITE_BIN="$MODDIR/bin/sqlite3"
LOGFILE="$MODDIR/lsposed_pogo.log"

# Fallback check
if [ ! -f "$SQLITE_BIN" ]; then
    SQLITE_BIN="sqlite3"
else
    chmod +x "$SQLITE_BIN"
fi

# --- LOGGING FUNCTION ---
# Prints to stdout and appends to the log file
log() {
    echo "$@" | tee -a "$LOGFILE"
}

# Initialize log
echo "--- Script started at $(date) ---" >> "$LOGFILE"

# --- CONFIGURATION ---
DB_PATH="/data/adb/lspd/config/modules_config.db"
MODULE_PKG="com.github.thepiemonster.hidemocklocation"
TARGET_APPS_LIST="system com.theappninjas.fakegpsjoystick com.nianticlabs.pokemongo com.nianticlabs.ingress com.nianticlabs.monsterhunter com.nianticlabs.pokemongo.ares"

if [ ! -f "$DB_PATH" ]; then
    log "Error: LSPosed DB not found."
    exit 1
fi

# --- CHECK MODULE STATUS ---
# Query the 'enabled' column from the 'modules' table.
# Schema: enabled BOOLEAN DEFAULT 0 CHECK (enabled IN (0, 1))
# 1 = Enabled, 0 = Disabled.
MODULE_STATUS=$("$SQLITE_BIN" "$DB_PATH" "SELECT enabled FROM modules WHERE module_pkg_name = '$MODULE_PKG' LIMIT 1;" 2>> "$LOGFILE")

if [ -z "$MODULE_STATUS" ]; then
    log "Error: Module $MODULE_PKG not found in database."
    exit 1
fi

if [ "$MODULE_STATUS" -ne 1 ]; then
    log "Module $MODULE_PKG is disabled. Enabling it now..."
    "$SQLITE_BIN" "$DB_PATH" "UPDATE modules SET enabled = 1 WHERE module_pkg_name = '$MODULE_PKG';" 2>> "$LOGFILE"
    log "Module $MODULE_PKG has been enabled."
else
    log "Module $MODULE_PKG is already enabled."
fi

log "Enforcing scopes..."

for APP in $TARGET_APPS_LIST; do
    # Use pm path for exact match and better performance than pm list | grep
    if [ "$APP" = "system" ] || pm path "$APP" > /dev/null 2>&1; then

        # Using a quoted string instead of heredoc to avoid syntax errors
        QUERY="INSERT OR IGNORE INTO scope (mid, app_pkg_name, user_id) SELECT mid, '$APP', 0 FROM modules WHERE module_pkg_name = '$MODULE_PKG';"
        "$SQLITE_BIN" "$DB_PATH" "$QUERY" 2>> "$LOGFILE"

        log "Status: Enforced scope for $APP."
    else
        log "Skipped: $APP is not installed."
    fi
done