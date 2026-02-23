    #!/system/bin/sh
    # --- ROM-Aware DNS Silencer for SoaresUtils ---

    LOG_FILE="/data/local/tmp/soaresutils.log"
    HOSTS_BACKDOOR="/data/adb/modules/hosts/system/etc/hosts"

    # 1. Force Private DNS Off to ensure hosts file is used
    echo "[DNS] Disabling Private DNS (forcing Legacy mode)..." >> "$LOG_FILE"
    settings put global private_dns_mode off

    # 2. Identify the ROM
    # Official LineageOS builds always carry the ro.lineage.version property
    IS_LINEAGE=$(getprop ro.lineage.version)

    if [ -n "$IS_LINEAGE" ]; then
        echo "[ROM] LineageOS detected ($IS_LINEAGE). Blocking Lineage + Google pings." >> "$LOG_FILE"
        BLOCK_LIST="download.lineageos.org stats.lineageos.org api.gpsjoystick.theappninjas.com"
    else
        echo "[ROM] Non-Lineage ROM detected. Blocking GPS Joystick pings only." >> "$LOG_FILE"
        BLOCK_LIST="api.gpsjoystick.theappninjas.com"
    fi

    # 3. Inject blocks into the Magisk Systemless Hosts file
    # We use 0.0.0.0 as it's slightly faster than 127.0.0.1 on modern Android
    if [ -f "$HOSTS_BACKDOOR" ]; then
        for domain in $BLOCK_LIST; do
            if ! grep -q "$domain" "$HOSTS_BACKDOOR"; then
                echo "[HOSTS] Adding block for: $domain" >> "$LOG_FILE"
                echo "0.0.0.0 $domain" >> "$HOSTS_BACKDOOR"
            else
                echo "[HOSTS] $domain already blocked. Skipping." >> "$LOG_FILE"
            fi
        done
    else
        echo "[ERROR] Magisk Systemless Hosts module not found or not active!" >> "$LOG_FILE"
    fi