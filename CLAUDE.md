# pop-updater

Daily automated system + app update for Pop!_OS 24.04 with Telegram summary notification.

## What it does
Runs as root via systemd at 07:30 WIB (Asia/Jakarta). Updates: APT, Flatpak, pip, npm global packages, and checks fwupdmgr firmware. Sends a Telegram message summarising which packages changed and their version diffs.

## Structure
- `pop-updater` — main bash script (no sudo, runs as root)
- `systemd/` — service and timer units
- `install.sh` / `uninstall.sh` — deployment helpers
- `secrets.conf.example` — credentials template (never commit the real one)

## Credentials
Stored at `/etc/pop-updater/secrets.conf` (root-only, `700/600`), never in the repo.
Variables: `TG_BOT_TOKEN`, `TG_CHAT_ID`.

## Deploy
```bash
sudo ./install.sh
```

## Debug
```bash
sudo systemctl start pop-updater.service
journalctl -u pop-updater.service -f
systemctl list-timers pop-updater.timer
```

## System info
- OS: Pop!_OS 24.04 LTS
- Timezone: Asia/Jakarta (WIB)
- Package managers handled: apt, flatpak, pip3, npm
