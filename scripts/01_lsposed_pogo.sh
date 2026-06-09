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
MIN_VERSION_CODE_WITHOUT_SYSTEM=220
SYSTEM_TARGET_APP="system"
TARGET_APPS_LIST_WITHOUT_SYSTEM="com.theappninjas.fakegpsjoystick com.nianticlabs.pokemongo com.nianticlabs.ingress com.nianticlabs.monsterhunter com.nianticlabs.pokemongo.ares com.missbrotowings.joystick"

get_module_version_code() {
    dumpsys package "$MODULE_PKG" 2>/dev/null | sed -n 's/.*versionCode=\([0-9][0-9]*\).*/\1/p' | head -n 1
}

build_target_apps_list() {
    VERSION_CODE="${1:-$(get_module_version_code)}"

    if [ -n "$VERSION_CODE" ] && [ "$VERSION_CODE" -ge "$MIN_VERSION_CODE_WITHOUT_SYSTEM" ]; then
        echo "$TARGET_APPS_LIST_WITHOUT_SYSTEM"
    else
        echo "$SYSTEM_TARGET_APP $TARGET_APPS_LIST_WITHOUT_SYSTEM"
    fi
}

if [ ! -f "$DB_PATH" ]; then
    log "Error: LSPosed DB not found."
    exit 1
fi

MODULE_VERSION_CODE=$(get_module_version_code)
TARGET_APPS_LIST=$(build_target_apps_list "$MODULE_VERSION_CODE")

if [ -n "$MODULE_VERSION_CODE" ] && [ "$MODULE_VERSION_CODE" -ge "$MIN_VERSION_CODE_WITHOUT_SYSTEM" ]; then
    log "Hide Mock Location versionCode=$MODULE_VERSION_CODE; skipping system scope."
else
    log "Hide Mock Location versionCode=${MODULE_VERSION_CODE:-unknown}; keeping system scope."
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
