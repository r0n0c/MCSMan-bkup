# MCSManager Minecraft Backup Script

This Bash script automates daily backups of Minecraft server instances managed by [MCSManager](https://github.com/MCSManager/MCSManager). It safely backs up instance data and removes backups older than 7 days.

## 🔧 Features

- Reads instance IDs from a text file
- Uses `rsync` for efficient incremental backups
- Retains backups for 7 days
- Outputs clean logs with local timezone timestamps

## 📁 Folder Structure

```
/your-backup-folder/
├── INST_LIST.txt # One instance ID per line
├── 2024-05-20-abc123 # Daily backup folders
└── mcbk.sh # This backup script
```

## 📜 Setup Instructions

1. Clone or copy this script to your backup folder.
2. Set your desired values in the script:
   - `BACKUP_BASE`: Where you want backups stored
   - `INSTANCE_LIST`: Path to a file listing instance IDs
   - `INSTANCE_BASE`: Location of instance data (default used by MCSManager)
   - `LOG_TZ`: Your preferred timezone for logs
3. Create an `INST_LIST.txt` file with one instance ID per line:
   ```
   abc123...
   def456...
   ```
4. Set up a cron job (after MCSManager shuts down servers):
   ```bash
   0 0 * * * /path/to/mcbk.sh >> /path/to/mcbk.log 2>&1
   ```

## 🕓 Timezone Support

You can customize the time zone used in logs by editing the LOG_TZ variable (e.g., "America/Chicago"). This does not affect the server time — only log formatting.

## 🧹 Retention

Backups older than 7 days are automatically deleted based on their folder name's date prefix (YYYY-MM-DD-<instance-id> format).

## ❗ Requirements

   - Bash
   - rsync
   - A working MCSManager environment (to stop and start your instances)
   - Proper permissions to read instance directories and write backups

## ✅ Example Cron Entry

```bash
# Run every night at midnight
0 0 * * * /path/to/mcbk.sh >> /path/to/mcbk.log 2>&1
```
## 🧪 Example Output

```bash
🚀 Minecraft Backup Started
🕒 Start Time: 2024-05-20 00:00:01 CDT
📁 Backup Base: /home/mc/backups
🔄 Backing up instance: abc123...
✅ Keeping recent backup: 2024-05-19-abc123
🗑️  Deleting old backup: 2024-05-12-abc123
✅ Minecraft Backup Completed
📦 Instances Backed Up:
   - abc123...
```
