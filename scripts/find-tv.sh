#!/bin/bash
# Cherche sur le Wi-Fi les appareils qui acceptent ADB (port 5555).
# La TV n'apparaît que si « Débogage ADB » est activé et qu'elle est allumée.
# Usage : ./scripts/find-tv.sh            (devine le réseau du Mac)
#         ./scripts/find-tv.sh 192.168.12  (réseau imposé)

NET="${1:-}"
if [ -z "$NET" ]; then
  IFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"
  MYIP="$(ipconfig getifaddr "${IFACE:-en0}" 2>/dev/null)"
  [ -n "$MYIP" ] || { echo "Impossible de trouver l'adresse du Mac. Usage : ./scripts/find-tv.sh 192.168.12"; exit 1; }
  NET="${MYIP%.*}"
  echo "Adresse du Mac : $MYIP"
fi

echo "Recherche des appareils avec ADB ouvert sur $NET.2 à $NET.254 (environ 20 secondes)..."
TMP="$(mktemp)"
for i in $(seq 2 254); do
  ( nc -z -G 1 "$NET.$i" 5555 >/dev/null 2>&1 && echo "$NET.$i" >> "$TMP" ) &
  [ $((i % 50)) -eq 0 ] && wait
done
wait

if [ -s "$TMP" ]; then
  echo
  echo "Appareil(s) trouvé(s) avec ADB ouvert :"
  sort -t. -k4 -n "$TMP" | sed 's/^/  /'
  echo
  echo "Connectez-vous avec : ./scripts/01-connect.sh $(sort -t. -k4 -n "$TMP" | head -1)"
else
  echo
  echo "Aucun appareil trouvé. Vérifiez sur la TV :"
  echo "  - qu'elle est allumée et sur le même Wi-Fi que le Mac ;"
  echo "  - Paramètres > Ma Fire TV > Options pour les développeurs > Débogage ADB : activé."
fi
rm -f "$TMP"
