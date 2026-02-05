#!/system/bin/sh

# ==============================================================================
# Ensures Zygisk is enabled in Magisk settings.
# Note: Changes require a reboot to take effect.
# ==============================================================================

# --- PATH SETUP ---
SCRIPT_DIR=${0%/*}
MODDIR=$(dirname "$SCRIPT_DIR")
SQLITE_BIN="$MODDIR/bin/sqlite3"

# Fallback check
[ ! -f "$SQLITE_BIN" ] && SQLITE_BIN="sqlite3"

DB_PATH="/data/adb/magisk.db"

# 1. Check current status using your "key" syntax
CURRENT_VAL=$("$SQLITE_BIN" "$DB_PATH" "SELECT value FROM settings WHERE key='zygisk';")

if [ "$CURRENT_VAL" = "1" ]; then
    echo "[ZYGISK] Already enabled. No action needed."
else
    echo "[ZYGISK] Current value is '$CURRENT_VAL'. Enabling now..."
    
    # 2. Try UPDATE first. If no rows affected, then INSERT.
    "$SQLITE_BIN" "$DB_PATH" "UPDATE settings SET value=1 WHERE key='zygisk';"
    
    # Verify
    NEW_VAL=$("$SQLITE_BIN" "$DB_PATH" "SELECT value FROM settings WHERE key='zygisk';")
    
    if [ "$NEW_VAL" = "1" ]; then
        echo "[ZYGISK] SUCCESS: Zygisk enabled. Please reboot."
    else
        echo "[ZYGISK] ERROR: Failed to update. Trying Force Insert..."
        "$SQLITE_BIN" "$DB_PATH" "INSERT OR IGNORE INTO settings (key, value) VALUES ('zygisk', 1);"

        # Final check after insert
        IF_SUCCESS=$("$SQLITE_BIN" "$DB_PATH" "SELECT value FROM settings WHERE key='zygisk';")
        [ "$IF_SUCCESS" = "1" ] && echo "[ZYGISK] SUCCESS (via Insert): PLEASE REBOOT."
    fi
fi