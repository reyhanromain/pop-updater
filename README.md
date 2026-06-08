# pop-updater

Automated daily system update for Pop!_OS with Telegram notification.

## What gets updated
- **APT** — system packages
- **Flatpak** — desktop apps
- **pip** — Python packages
- **npm** — global Node packages
- **fwupdmgr** — firmware

## Telegram summary
After each run, a message is sent with per-package version diffs:

```
🖥️ pop-updater — 2026-06-08 07:30 WIB

📦 APT (2 updated)
  • curl: 8.5.0 → 8.7.1
  • git: 2.43.0 → 2.45.2

📱 Flatpak — nothing to update
🐍 pip — nothing to update
📦 npm — nothing to update
🔧 Firmware — no updates available

⏱️ Duration: 1m 22s
```

## Install

```bash
git clone https://github.com/reyhanromain/pop-updater ~/github/pop-updater
cd ~/github/pop-updater
sudo ./install.sh
```

`install.sh` will prompt for your Telegram bot token and chat ID, then:
- Deploy the script to `/usr/local/bin/pop-updater`
- Store credentials in `/etc/pop-updater/secrets.conf` (root-only)
- Install and enable the systemd timer (runs daily at 07:30 WIB)

## Manual run

```bash
update        # via zshrc alias
# or
sudo /usr/local/bin/pop-updater
```

## Debug

```bash
sudo systemctl start pop-updater.service
journalctl -u pop-updater.service -f
systemctl list-timers pop-updater.timer
```

## Uninstall

```bash
sudo ./uninstall.sh
```
