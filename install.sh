#!/usr/bin/env bash
# install.sh — deploy pop-updater to the system
# Run with: sudo ./install.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo ./install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "${GREEN}[OK]${NC} $1"; }

# 1. Deploy main script
install -m 755 -o root -g root "$SCRIPT_DIR/pop-updater" /usr/local/bin/pop-updater
ok "Script installed to /usr/local/bin/pop-updater"

# 2. Deploy tar app scripts
mkdir -p /usr/local/lib/pop-updater/tar-app-scripts
if compgen -G "$SCRIPT_DIR/tar-app-scripts/*" >/dev/null; then
    for script in "$SCRIPT_DIR"/tar-app-scripts/*; do
        [[ -f "$script" ]] || continue
        install -m 755 -o root -g root "$script" "/usr/local/lib/pop-updater/tar-app-scripts/$(basename "$script")"
    done
fi
mkdir -p /var/cache/pop-updater/tar /var/lib/pop-updater/tar
chmod 755 /var/cache/pop-updater /var/cache/pop-updater/tar /var/lib/pop-updater /var/lib/pop-updater/tar
rm -f /usr/local/bin/update-postman
ok "Tar app scripts installed"

# 3. Create secrets directory
mkdir -p /etc/pop-updater
chmod 700 /etc/pop-updater
chown root:root /etc/pop-updater

# 4. Create secrets.conf if not exists
if [[ ! -f /etc/pop-updater/secrets.conf ]]; then
    read -rp "TG_BOT_TOKEN: " TG_BOT_TOKEN
    read -rp "TG_CHAT_ID: " TG_CHAT_ID
    cat > /etc/pop-updater/secrets.conf <<EOF
TG_BOT_TOKEN=${TG_BOT_TOKEN}
TG_CHAT_ID=${TG_CHAT_ID}
EOF
    chmod 600 /etc/pop-updater/secrets.conf
    chown root:root /etc/pop-updater/secrets.conf
    ok "Credentials saved to /etc/pop-updater/secrets.conf"
else
    ok "Credentials already exist — skipping"
fi

# 5. Create tar apps config if not exists
if [[ ! -f /etc/pop-updater/tar-apps.conf ]]; then
    cat > /etc/pop-updater/tar-apps.conf <<EOF
# Enable standalone tarball app updaters with app=on.
# Disable an app with app=off.
postman=on
EOF
    chmod 600 /etc/pop-updater/tar-apps.conf
    chown root:root /etc/pop-updater/tar-apps.conf
    ok "Tar apps config saved to /etc/pop-updater/tar-apps.conf"
else
    ok "Tar apps config already exists — skipping"
fi

# 6. Deploy systemd units
install -m 644 -o root -g root "$SCRIPT_DIR/systemd/pop-updater.service" /etc/systemd/system/pop-updater.service
install -m 644 -o root -g root "$SCRIPT_DIR/systemd/pop-updater.timer" /etc/systemd/system/pop-updater.timer
ok "systemd units installed"

# 7. Enable and start timer
systemctl daemon-reload
systemctl enable --now pop-updater.timer
ok "Timer enabled and started"

echo ""
echo "Next trigger:"
systemctl list-timers pop-updater.timer --no-pager
