#!/system/bin/sh
MODDIR=${0%/*}
LOG_FILE="/data/local/tmp/soaresutils.log"

# Setup the screen handle
exec 5>&1

echo "[$(date)] --- ACTION BUTTON PRESSED ---" | tee -a "$LOG_FILE" >&5

# Loop through scripts
count=0
for script in "$MODDIR/scripts/"*.sh; do
    if [ -f "$script" ]; then
        
        # Print "Running..." to both
        echo "[$(date)] Running: ${script##*/}" | tee -a "$LOG_FILE" >&5
        
        # --- THE MAGIC LINE ---
        # Run the script, showing output on Screen AND saving to Log
        sh "$script" 2>&1 | tee -a "$LOG_FILE" >&5
        # ----------------------
        
        count=$((count + 1))
    fi
done

if [ "$count" -eq 0 ]; then
    echo "[$(date)] No scripts found!" | tee -a "$LOG_FILE" >&5
else
    echo "[$(date)] Finished executing $count scripts." | tee -a "$LOG_FILE" >&5
fi

# Close the screen handle
exec 5>&-