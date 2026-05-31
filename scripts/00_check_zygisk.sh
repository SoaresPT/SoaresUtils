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
ZYGISK_MODULES_DIR="${ZYGISK_MODULES_DIR:-/data/adb/modules}"

# Skip native Magisk Zygisk enforcement when an active standalone Zygisk
# provider is installed. These providers conflict with native Zygisk.
for MODULE_DIR in "$ZYGISK_MODULES_DIR"/*; do
    PROP_FILE="$MODULE_DIR/module.prop"

    [ -f "$PROP_FILE" ] || continue
    [ -f "$MODULE_DIR/disable" ] && continue
    [ -f "$MODULE_DIR/remove" ] && continue

    if grep -qi '^id=rezygisk$' "$PROP_FILE" || \
       grep -qi '^name=rezygisk$' "$PROP_FILE" || \
       grep -qi '^id=zygisksu$' "$PROP_FILE" || \
       grep -qi '^id=zygisknext$' "$PROP_FILE" || \
       grep -qi '^name=zygisk next$' "$PROP_FILE" || \
       grep -qi '^id=neozygisk$' "$PROP_FILE" || \
       grep -qi '^name=neozygisk$' "$PROP_FILE" || \
       grep -qi '^description=.*standalone implementation of zygisk' "$PROP_FILE"; then
        echo "[ZYGISK] Standalone Zygisk provider detected. Skipping native Zygisk enable."
        exit 0
    fi
done

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
