#!/system/bin/sh

# ==============================================================================
# Disables Nothing/Google OTA update services on every boot.
# Restricts execution strictly to Stock Nothing OS environments.
# ==============================================================================

# 1. Loop and wait until Android says it is fully booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 3
done

# 2. Give the system an extra 15 seconds to let the framework settle
sleep 15

# 3. STRICT STOCK CHECK: Does the Nothing Offline Updater actually exist?
# The '-u' flag ensures it checks all apps, even uninstalled/disabled ones.
if ! pm list packages -u | grep -q "com.nothing.OfflineOTAUpgradeApp"; then
    echo "[OTA BLOCK] Stock Nothing Updater not found. Likely a Custom ROM. Aborting."
    exit 0
fi

# 4. Nuke the Google Play Services OTA components
pm disable com.google.android.gms/.update.SystemUpdateService
pm disable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm disable com.google.android.gms/.update.SystemUpdateService$Receiver
pm disable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver

# 5. Nuke Nothing's offline update wizard
pm disable com.nothing.OfflineOTAUpgradeApp

echo "[OTA BLOCK] OTA services successfully disabled for this Stock Nothing OS boot cycle."