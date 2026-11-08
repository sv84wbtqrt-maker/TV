#!/bin/bash
# Étape 1 : se connecter à la TV en Wi-Fi et retenir son adresse IP.
# Usage : ./scripts/01-connect.sh 192.168.1.42
. "$(dirname "$0")/lib.sh"

IP="${1:-${TV_IP:-}}"
[ -n "$IP" ] || die "Indiquez l'adresse IP : ./scripts/01-connect.sh 192.168.1.42 (TV : Paramètres > Ma Fire TV > À propos > Réseau)"

echo "Connexion à $IP:5555..."
echo "Si une fenêtre « Autoriser le débogage USB ? » apparaît sur la TV, cochez « Toujours autoriser » puis OK."
adb connect "$IP:5555"

echo "TV_IP=\"$IP\"" > "$CONFIG"
TV_IP="$IP"
load_device

echo
echo "Connecté. Modèle : $(tv getprop ro.product.model) | Fire OS : $(tv getprop ro.build.version.name) | Android $(tv getprop ro.build.version.release)"
echo "Suite : ./scripts/02-audit.sh"
