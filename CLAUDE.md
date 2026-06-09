# pop-updater

Daily automated system + app update for Pop!_OS 24.04 with Telegram summary notification.

## What it does
Runs as root via systemd at 07:30 WIB (Asia/Jakarta). Updates: APT, Flatpak, pip, npm global packages, configurable tarball apps, and checks fwupdmgr firmware. Sends a Telegram message summarising which packages changed and their version diffs.

## Structure
- `pop-updater` — main bash script (no sudo, runs as root)
- `tar-app-scripts/` — standalone tarball app updater scripts
- `systemd/` — service and timer units
- `install.sh` / `uninstall.sh` — deployment helpers
- `secrets.conf.example` — credentials template (never commit the real one)

## Credentials
Stored at `/etc/pop-updater/secrets.conf` (root-only, `700/600`), never in the repo.
Variables: `TG_BOT_TOKEN`, `TG_CHAT_ID`.

## Tar apps
Configured at `/etc/pop-updater/tar-apps.conf` with simple `app=on` or `app=off` lines. The app key must match an executable script name installed under `/usr/local/lib/pop-updater/tar-app-scripts/`.

Repo scripts live in `tar-app-scripts/`. Each script owns app-specific update logic and must print one final result line:

```bash
RESULT app=Postman status=updated old=12.13.6 new=12.14.0 message=
```

Supported statuses: `updated`, `current`, `failed`, `skipped`. Values must not contain spaces; use underscores in `message`.

Postman paths:
- App: `/opt/Postman`
- Tar cache: `/var/cache/pop-updater/tar/postman/postman-linux-x64.tar.gz`
- Metadata: `/var/lib/pop-updater/tar/postman/`
- Command: `/usr/local/bin/postman`
- Launcher: `/usr/share/applications/postman.desktop`

Keep global tar app installs root-owned after install/sync so app-native self-updaters cannot change the managed install outside `pop-updater`.

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
- Tar apps handled: Postman
