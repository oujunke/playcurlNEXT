#!/system/bin/sh

###################################################################
# Check if boot is completed
###################################################################
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 10
done

# Sleep 10 seconds 
sleep 10

###################################################################
# Declare vars
###################################################################
# Detect busybox path
busybox_path=""
log_path="/data/adb/playcurl.log"

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
else
    echo "Busybox not found, exiting." > "$log_path"
    exit 1
fi
###################################################################

###################################################################
# Copy and set up cron script
###################################################################
pif_folder="/data/adb/modules/playintegrityfix"
MODULE_PROP="/data/adb/modules/playcurlNEXT/module.prop"

# Check if any supported PIF script exists
if [ -f "$pif_folder/action.sh" ] || [ -f "$pif_folder/autopif.sh" ] || [ -f "$pif_folder/autopif_ota.sh" ] || [ -f "$pif_folder/autopif2.sh" ]; then
    # Supported environment - at least one PIF implementation exists
    $busybox_path sed -i 's/^description=.*/description=Supported environment/' "$MODULE_PROP"
    echo "Supported environment" > "$log_path"
else
    # No supported PIF implementation found
    $busybox_path sed -i 's/^description=.*/description=Unsupported environment, update pif!/' "$MODULE_PROP"
    echo "Unsupported environment, update pif!" > "$log_path"
    exit 1
fi

###################################################################

###################################################################
# Read minutes from configuration
###################################################################
# Read minutes from the action (default to 60 minutes if the action doesn't exist or has an invalid value)
minutes=60
if [ -f "/data/adb/modules/playcurlNEXT/minutes.txt" ]; then
    read_minutes=$(cat /data/adb/modules/playcurlNEXT/minutes.txt)
    
    # Ensure it's a valid positive integer
    if [ "$read_minutes" -ge 1 ] 2>/dev/null; then
        # Ensure the value is between 1 and 1440 minutes
        if [ "$read_minutes" -gt 1440 ]; then
            minutes=1440
            echo "Minutes value exceeds 24 hours. Setting to maximum of 1440 minutes (24 hours)."
        elif [ "$read_minutes" -lt 1 ]; then
            minutes=1
            echo "Minutes value is below 1 minute. Setting to minimum of 1 minute."
        else
            minutes=$read_minutes
        fi
    else
        echo "Invalid value in minutes.txt. Defaulting to 1 hour."
    fi
else
    echo "action minutes.txt is missing. Defaulting to 1 hour."
fi
###################################################################

###################################################################
# Set up the cron job
###################################################################
# Ensure crontab directory exists
mkdir -p /data/cron

# Check if pc cron exists
if [ -f "/data/cron/root" ]; then
    rm -f "/data/cron/root"
fi

# Set up the cron job with the specified interval in minutes
module_contents=$("$busybox_path" cat /data/adb/modules/playintegrityfix/module.prop)

if [ -f "/data/adb/modules/playintegrityfix/autopif.sh" ] || [ -f "/data/adb/modules/playintegrityfix/autopif_ota.sh" ]; then
    echo "*/$minutes * * * * /system/bin/sh /data/adb/modules/playintegrityfix/autopif.sh -p" > /data/cron/root
elif ! echo "$module_contents" | "$busybox_path" grep -q 'Play Integrity Fork'; then
    echo "*/$minutes * * * * /system/bin/sh /data/adb/modules/playintegrityfix/action.sh" > /data/cron/root
else
    echo "*/$minutes * * * * /system/bin/sh /data/adb/modules/playintegrityfix/autopif2.sh -p" > /data/cron/root
fi

###################################################################

###################################################################
# Initialize and run scripts
###################################################################
# Init log
echo "Phone started..." > "$log_path"
echo "" >> "$log_path"

# Run once
if [ -f "/data/adb/modules/playintegrityfix/autopif.sh" ] || [ -f "/data/adb/modules/playintegrityfix/autopif_ota.sh" ]; then
    if [ -f "/data/adb/modules/playintegrityfix/autopif_ota.sh" ]; then
        /system/bin/sh /data/adb/modules/playintegrityfix/autopif_ota.sh >> "$log_path" || true
    fi
    /system/bin/sh /data/adb/modules/playintegrityfix/autopif.sh -p >> "$log_path"
elif ! echo "$module_contents" | "$busybox_path" grep -q 'Play Integrity Fork'; then
    /system/bin/sh /data/adb/modules/playintegrityfix/action.sh >> "$log_path"
else
    # grep() migrate.sh 
    if ! grep -q '^grep()[[:space:]]*{' /data/adb/modules/playintegrityfix/migrate.sh; then
        sed -i '1a\
BUSYBOX="'"$busybox_path"'"\
grep() { "$BUSYBOX" grep "$@"; }' /data/adb/modules/playintegrityfix/migrate.sh
    fi

    # grep() autopif2.sh
    if ! grep -q '^grep()[[:space:]]*{' /data/adb/modules/playintegrityfix/autopif2.sh; then
        sed -i '1a\
BUSYBOX="'"$busybox_path"'"\
grep() { "$BUSYBOX" grep "$@"; }' /data/adb/modules/playintegrityfix/autopif2.sh
    fi

    /system/bin/sh /data/adb/modules/playintegrityfix/autopif2.sh -p >> "$log_path"
fi

###################################################################
# Fix CRLF and set executable permissions for all .sh files
###################################################################
for file in /data/adb/modules/playintegrityfix/*.sh; do
    if [ -f "$file" ]; then
        echo "Fixing permissions and line endings: $file" >> "$log_path"
        $busybox_path sed -i 's/\r$//' "$file"
        chmod +x "$file"
    fi
done

###################################################################
# Start cron daemon
###################################################################
"$busybox_path" crond -c /data/cron -L "$log_path"
###################################################################