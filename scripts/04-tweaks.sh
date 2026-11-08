#!/bin/bash
# Étape 4 : réglages de vitesse.
# - animations désactivées (l'interface paraît beaucoup plus rapide) ;
# - mise en veille après 5 minutes d'inactivité (la lecture vidéo empêche la veille).
# Les anciennes valeurs sont sauvegardées dans state/settings-backup.txt (restauration : 99-undo.sh).
. "$(dirname "$0")/lib.sh"
load_device

FIVE_MIN=300000

backup_and_set() { # $1 = espace (global/system/secure), $2 = clé, $3 = nouvelle valeur
  local old; old="$(tv settings get "$1" "$2")"
  if ! grep -q "^$1 $2 " "$SETTINGS_BACKUP" 2>/dev/null; then
    echo "$1 $2 $old" >> "$SETTINGS_BACKUP"   # on ne garde que la toute première valeur d'origine
  fi
  tv settings put "$1" "$2" "$3"
  echo "$1/$2 : $old -> $(tv settings get "$1" "$2")"
}

echo "== Animations =="
backup_and_set global window_animation_scale 0
backup_and_set global transition_animation_scale 0
backup_and_set global animator_duration_scale 0

echo "== Veille après 5 minutes =="
# On ne modifie que les clés qui existent déjà sur cette TV.
for k in "system screen_off_timeout" "secure sleep_timeout"; do
  set -- $k
  cur="$(tv settings get "$1" "$2")"
  if [ "$cur" = "null" ] || [ -z "$cur" ]; then
    echo "$1/$2 : n'existe pas sur cette TV, ignoré"
  else
    backup_and_set "$1" "$2" "$FIVE_MIN"
  fi
done

echo
echo "Vérifiez aussi sur la TV : Paramètres > Affichage et sons (ou Préférences) > Veille / Économiseur d'écran."
echo "Sauvegarde des anciennes valeurs : $SETTINGS_BACKUP"
