#!/bin/bash
# Étape 1 : se connecter à la TV en Wi-Fi et retenir son adresse IP.
# Usage : ./scripts/01-connect.sh 192.168.1.42
. "$(dirname "$0")/lib.sh"

IP="${1:-${TV_IP:-}}"
[ -n "$IP" ] || die "Indiquez l'adresse IP : ./scripts/01-connect.sh 192.168.1.42 (TV : Paramètres > Ma Fire TV > À propos > Réseau)"

echo "$IP" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || die "« $IP » n'est pas une adresse valide. Exemple : 192.168.12.150 (4 nombres séparés par des points)."
case "$IP" in
  *.1) echo "ATTENTION : une adresse en .1 est en général la box internet, pas la TV."
       echo "Lancez ./scripts/find-tv.sh pour trouver la TV."; echo ;;
esac

echo "Connexion à $IP:5555..."
echo "Si une fenêtre « Autoriser le débogage USB ? » apparaît sur la TV, cochez « Toujours autoriser » puis OK."
rm -f "$CONFIG"   # oublie toute ancienne adresse
adb connect "$IP:5555"

# Attendre (jusqu'à 60 s) que la demande soit acceptée sur la TV.
i=0
while [ $i -lt 30 ]; do
  st="$(adb -s "$IP:5555" get-state 2>&1 || true)"
  case "$st" in
    device) break ;;
    *unauthorized*|*authenticat*) [ $i -eq 0 ] && echo "En attente : acceptez la demande sur la TV (cochez « Toujours autoriser »)..." ;;
    *) adb connect "$IP:5555" >/dev/null 2>&1 || true ;;
  esac
  sleep 2; i=$((i+1))
done

TV_IP="$IP"
load_device
echo "TV_IP=\"$IP\"" > "$CONFIG"   # on ne retient l'adresse que si la connexion a réussi

echo
echo "Connecté. Modèle : $(tv getprop ro.product.model) | Fire OS : $(tv getprop ro.build.version.name) | Android $(tv getprop ro.build.version.release)"
echo "Suite : ./scripts/02-audit.sh"
