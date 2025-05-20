#!/bin/bash

# MCSManager Minecraft Backup Script
# Backs up listed Minecraft instances and removes backups older than 7 days

# Configurable paths
BACKUP_BASE="/path/to/backup/folder"           # <-- Set this to your desired backup location
INSTANCE_LIST="${BACKUP_BASE}/INST_LIST.txt"   # File containing one instance ID per line
INSTANCE_BASE="/opt/mcsmanager/daemon/data/InstanceData"  # Default instance location for MCSManager

# Time zone for log output (e.g., America/Chicago)
LOG_TZ="America/Chicago"
DATE_PREFIX=$(date +%F)
START_TIME=$(TZ=$LOG_TZ date '+%F %T %Z')

# Header
echo "==============================================="
echo "🚀 Minecraft Backup Started"
echo "🕒 Start Time: $START_TIME"
echo "📁 Backup Base: $BACKUP_BASE"
echo "==============================================="

# Sanity check
if [[ ! -f "$INSTANCE_LIST" ]]; then
    echo "❌ Instance list file not found: $INSTANCE_LIST"
    exit 1
fi

cutoff_epoch=$(date -d "7 days ago" +%s)
BACKED_UP_IDS=()

while IFS= read -r INST_ID || [[ -n "$INST_ID" ]]; do
    [[ -z "$INST_ID" ]] && continue

    SOURCE_DIR="${INSTANCE_BASE}/${INST_ID}"
    DEST_DIR="${BACKUP_BASE}/${DATE_PREFIX}-${INST_ID}"

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "⚠️  Source directory not found for instance: $INST_ID"
        continue
    fi

    echo "🔄 Backing up instance: $INST_ID"
    rsync -a --quiet "${SOURCE_DIR}/" "${DEST_DIR}/"
    if [[ $? -ne 0 ]]; then
        echo "❌ Error during rsync for instance: $INST_ID"
        continue
    fi

    BACKED_UP_IDS+=("$INST_ID")

    for dir in "${BACKUP_BASE}"/*-"${INST_ID}"; do
        [[ -d "$dir" ]] || continue

        dir_name=$(basename "$dir")
        dir_date="${dir_name%%-${INST_ID}}"

        if [[ "$dir_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            dir_epoch=$(date -d "$dir_date" +%s)
            if (( dir_epoch < cutoff_epoch )); then
                echo "🗑️  Deleting old backup: $dir"
                rm -rf "$dir"
            else
                echo "✅ Keeping recent backup: $dir"
            fi
        else
            echo "⚠️  Skipping (invalid date format): $dir_name"
        fi
    done
done < "$INSTANCE_LIST"

END_TIME=$(TZ=$LOG_TZ date '+%F %T %Z')
echo "==============================================="
echo "✅ Minecraft Backup Completed"
echo "🕒 End Time: $END_TIME"
echo "📦 Instances Backed Up:"
for id in "${BACKED_UP_IDS[@]}"; do
    echo "   - $id"
done
echo "==============================================="
