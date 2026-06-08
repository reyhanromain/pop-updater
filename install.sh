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

# 2. Create secrets directory
mkdir -p /etc/pop-updater
chmod 700 /etc/pop-updater
chown root:root /etc/pop-updater

# 3. Create secrets.conf if not exists
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

# 4. Deploy systemd units
install -m 644 -o root -g root "$SCRIPT_DIR/systemd/pop-updater.service" /etc/systemd/system/pop-updater.service
install -m 644 -o root -g root "$SCRIPT_DIR/systemd/pop-updater.timer" /etc/systemd/system/pop-updater.timer
ok "systemd units installed"

# 5. Enable and start timer
systemctl daemon-reload
systemctl enable --now pop-updater.timer
ok "Timer enabled and started"

echo ""
echo "Next trigger:"
systemctl list-timers pop-updater.timer --no-pager
