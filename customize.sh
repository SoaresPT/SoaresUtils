#!/system/bin/sh
SKIPUNZIP=1

# Extract files
unzip -o "$ZIPFILE" -d "$MODPATH" >&2

# Set permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/scripts 0 0 0755 0755  # Make scripts executable
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755  # Make binaries executable
set_perm_recursive $MODPATH/bin 0 0 0755 0755  # Make binaries executable
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/action.sh 0 0 0755