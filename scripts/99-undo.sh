#!/bin/bash
# ANNULER : réactive les applis désactivées et restaure les réglages d'origine.
# Usage :
#   ./scripts/99-undo.sh              -> tout annuler
#   ./scripts/99-undo.sh com.exemple  -> réactiver une seule appli
. "$(dirname "$0")/lib.sh"
load_device

if [ $# -gt 0 ]; then
  for p in "$@"; do
    echo "$p : $(tv pm enable --user 0 "$p" 2>&1)"
  done
  exit 0
fi

if [ -f "$UNDO_LIST" ]; then
  echo "== Réactivation des applis =="
  awk '{print $3}' "$UNDO_LIST" | sort -u | while read -r p; do
    [ -n "$p" ] && echo "$p : $(tv pm enable --user 0 "$p" 2>&1)"
  done
  mv "$UNDO_LIST" "$UNDO_LIST.undone-$(date +%Y%m%d%H%M)"
else
  echo "Aucune appli à réactiver."
fi

if [ -f "$SETTINGS_BACKUP" ]; then
  echo "== Restauration des réglages =="
  while read -r ns key val; do
    [ -n "$key" ] || continue
    if [ "$val" = "null" ] || [ -z "$val" ]; then
      tv settings delete "$ns" "$key" >/dev/null
      echo "$ns/$key : supprimé (valeur par défaut)"
    else
      tv settings put "$ns" "$key" "$val"
      echo "$ns/$key : remis à $val"
    fi
  done < "$SETTINGS_BACKUP"
  mv "$SETTINGS_BACKUP" "$SETTINGS_BACKUP.undone-$(date +%Y%m%d%H%M)"
else
  echo "Aucun réglage à restaurer."
fi

echo
echo "Annulation terminée. Redémarrez la TV : ./scripts/05-reboot-check.sh"
