by CloudDras
#!/bin/bash

# Pad naar backupmap
BACKUP_DIR="/backup/proxy-backups"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="$BACKUP_DIR/proxy-backup-$TIMESTAMP.tar.gz"

# Te backuppen paden
CONFIG_PATHS=(
  "/etc/apache2/sites-available"
  "/etc/apache2/sites-enabled"
  "/etc/letsencrypt/live/$DOMAIN_NAME"
  "/etc/letsencrypt/archive/$DOMAIN_NAME"
)

# Backupmap maken als deze niet bestaat
mkdir -p "$BACKUP_DIR"

# Tar maken
tar -czf "$BACKUP_FILE" "${CONFIG_PATHS[@]}"

# Resultaat tonen
echo "✅ Apache proxy backup gemaakt:"
echo "$BACKUP_FILE"
