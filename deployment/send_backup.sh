#!/bin/bash
set -e

# Send backup notification to Telegram
# This script is called after a successful backup

BACKUP_FILE="$1"

if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Telegram credentials not configured, skipping notification"
    exit 0
fi

if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    MESSAGE="Backup completed: $(basename "$BACKUP_FILE") (${FILE_SIZE})"
else
    MESSAGE="Backup completed successfully"
fi

curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${MESSAGE}" \
    > /dev/null

echo "Notification sent to Telegram"
