# pop-updater

Automated daily system update for Pop!_OS with Telegram notification.

## What gets updated
- **APT** — system packages
- **Flatpak** — desktop apps
- **pip** — Python packages
- **npm** — global Node packages
- **fwupdmgr** — firmware
- **Tar apps** — standalone tarball apps such as Postman

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
📦 Tar apps — all up to date
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
- Deploy tar app scripts to `/usr/local/lib/pop-updater/tar-app-scripts/`
- Store credentials in `/etc/pop-updater/secrets.conf` (root-only)
- Create `/etc/pop-updater/tar-apps.conf` if missing
- Install and enable the systemd timer (runs daily at 07:30 WIB)

## Tar apps

Tar apps are apps distributed as standalone tarballs instead of APT, Flatpak, npm, or pip packages.
Each tar app has its own script in `tar-app-scripts/`, and the script name is the app key.

Enable or disable tar apps in:

```bash
sudoedit /etc/pop-updater/tar-apps.conf
```

Example:

```bash
postman=on
```

Supported values:
- `on` — run the matching script
- `off` — skip it

Postman is managed globally:
- App: `/opt/Postman`
- Tar cache: `/var/cache/pop-updater/tar/postman/postman-linux-x64.tar.gz`
- Metadata: `/var/lib/pop-updater/tar/postman/`
- Command: `/usr/local/bin/postman`
- Launcher: `/usr/share/applications/postman.desktop`

The global Postman install is kept root-owned so updates are controlled by `pop-updater`, not Postman's in-app updater.

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
