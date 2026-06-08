#!/usr/bin/env bash
# uninstall.sh — remove pop-updater from the system
# Run with: sudo ./uninstall.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo ./uninstall.sh"
    exit 1
fi

systemctl disable --now pop-updater.timer 2>/dev/null || true
systemctl stop pop-updater.service 2>/dev/null || true

rm -f /etc/systemd/system/pop-updater.service
rm -f /etc/systemd/system/pop-updater.timer
rm -f /usr/local/bin/pop-updater
rm -rf /usr/local/lib/pop-updater/tar-app-scripts
rm -rf /var/cache/pop-updater/tar
rm -rf /var/lib/pop-updater/tar
systemctl daemon-reload

echo "Uninstalled. /etc/pop-updater/secrets.conf was kept — remove manually if desired:"
echo "  sudo rm -rf /etc/pop-updater"
echo "Tar apps config and installed apps were kept:"
echo "  /etc/pop-updater/tar-apps.conf"
echo "  /opt/Postman"
