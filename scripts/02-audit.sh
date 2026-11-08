#!/bin/bash
# Étape 2 : inventaire en LECTURE SEULE. Ne modifie rien sur la TV.
# Crée un dossier audit/<date>/ avec la liste des applis, la mémoire et les réglages actuels.
. "$(dirname "$0")/lib.sh"
load_device

OUT="$AUDIT/$(date +%Y-%m-%d_%H%M)"
mkdir -p "$OUT"

echo "Inventaire en cours dans $OUT ..."
{
  echo "model=$(tv getprop ro.product.model)"
  echo "fireos=$(tv getprop ro.build.version.name)"
  echo "android=$(tv getprop ro.build.version.release)"
  echo "build=$(tv getprop ro.build.display.id)"
} > "$OUT/device.txt"

tv pm list packages -s  | sed 's/^package://' | sort > "$OUT/system-apps.txt"
tv pm list packages -3  | sed 's/^package://' | sort > "$OUT/installed-apps.txt"
tv pm list packages -d  | sed 's/^package://' | sort > "$OUT/already-disabled.txt"
tv pm list packages -e  | sed 's/^package://' | sort > "$OUT/enabled-apps.txt"

tv cat /proc/meminfo | head -5 > "$OUT/memory.txt"
tv dumpsys meminfo 2>/dev/null | sed -n '/Total PSS by process/,/Total PSS by OOM/p' | head -40 > "$OUT/top-memory.txt"

for k in "global window_animation_scale" "global transition_animation_scale" "global animator_duration_scale" \
         "system screen_off_timeout" "secure sleep_timeout" "secure screensaver_enabled"; do
  echo "$k = $(tv settings get $k)"
done > "$OUT/settings.txt"

# Pour chaque appli système : protégée par le filet de sécurité ou non.
: > "$OUT/system-apps-classified.txt"
while read -r p; do
  [ -n "$p" ] || continue
  if is_protected "$p"; then echo "PROTEGEE  $p"; else echo "A_EXAMINER $p"; fi
done < "$OUT/system-apps.txt" >> "$OUT/system-apps-classified.txt"

echo
echo "Applis système : $(wc -l < "$OUT/system-apps.txt" | tr -d ' ') | installées par vous : $(wc -l < "$OUT/installed-apps.txt" | tr -d ' ') | déjà désactivées : $(wc -l < "$OUT/already-disabled.txt" | tr -d ' ')"
grep -E 'MemTotal|MemAvailable' "$OUT/memory.txt"
echo
echo "Envoyez le dossier $OUT à Claude (ou faites git add audit && git commit && git push)."
echo "Aucune modification n'a été faite sur la TV."
