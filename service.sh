#!/system/bin/sh
MODDIR=${0%/*}
LOG_FILE="/data/local/tmp/soaresutils.log"

# Clear previous log on boot
echo "========================================" > "$LOG_FILE"
echo " SoaresUtils - Boot Sequence | $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# 1. Wait for Boot Completion
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

echo "[STATUS] System Booted & Storage Ready | $(date)" >> "$LOG_FILE"

# 2. Execute all scripts in the scripts/ directory
count=0
for script in "$MODDIR/scripts/"*.sh; do
    if [ -f "$script" ]; then
        echo "[EXEC] Running: ${script##*/}" >> "$LOG_FILE"
        # Run in background? Remove '&' if you want them sequential
        sh "$script" >> "$LOG_FILE" 2>&1
        count=$((count + 1))
    fi
done

if [ "$count" -eq 0 ]; then
    echo "[INFO] No active scripts found." >> "$LOG_FILE"
fi