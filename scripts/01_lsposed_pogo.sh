#!/system/bin/sh

# ==============================================================================
# Sets LSPosed module scope for multiple Niatic Games on boot and when triggering the Action Button.
# ==============================================================================

# --- CONFIGURATION ---
DB_PATH="/data/adb/lspd/config/modules_config.db"
MODULE_PKG="com.github.thepiemonster.hidemocklocation"
TARGET_APPS_LIST="system com.nianticlabs.pokemongo com.nianticlabs.ingress com.nianticlabs.monsterhunter com.nianticlabs.pokemongo.ares"

if [ ! -f "$DB_PATH" ]; then
    echo "Error: LSPosed DB not found."
    exit 1
fi

for APP in $TARGET_APPS_LIST; do
    if pm list packages | grep -q "$APP"; then
        # Inject into Database
        sqlite3 "$DB_PATH" <<EOF
        INSERT OR IGNORE INTO scope (mid, app_pkg_name, user_id)
        SELECT mid, '$APP', 0
        FROM modules
        WHERE module_pkg_name = '$MODULE_PKG';
EOF
        echo "Status: Enforced scope for $APP."
    else
        echo "Skipped: $APP is not installed."
    fi
done