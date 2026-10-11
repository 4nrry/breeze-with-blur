#!/usr/bin/env bash
# Desfaz o install.sh: restaura os valores guardados no backup e remove os arquivos instalados.
set -euo pipefail

data="${XDG_DATA_HOME:-$HOME/.local/share}"
conf="${XDG_CONFIG_HOME:-$HOME/.config}"
state="$data/breeze-by-4nrry"
backup="$state/backup.ini"

[ -f "$backup" ] || { echo "nada para desfazer: $backup não existe" >&2; exit 1; }

groups() { local IFS='>'; for g in $1; do printf -- '--group\0%s\0' "$g"; done; }

echo "== Restaurando configurações"
while IFS= read -r line; do
    file="${line%%|*}"; rest="${line#*|}"
    group="${rest%%|*}"; rest="${rest#*|}"
    key="${rest%%=*}"; old="${rest#*=}"
    args=()
    while IFS= read -r -d '' a; do args+=("$a"); done < <(groups "$group")
    if [ -z "$old" ]; then
        kwriteconfig6 --file "$file" "${args[@]}" --key "$key" --delete
    else
        kwriteconfig6 --file "$file" "${args[@]}" --key "$key" "$old"
    fi
done < "$backup"

theme="$(kreadconfig6 --file plasmarc --group Theme --key name)"
plasma-apply-desktoptheme "${theme:-default}" || true
icons="$(kreadconfig6 --file kdeglobals --group Icons --key Theme)"
changeicons="$(ls /usr/lib/*/libexec/plasma-changeicons /usr/libexec/plasma-changeicons 2>/dev/null | head -1 || true)"
[ -n "$changeicons" ] && "$changeicons" "${icons:-breeze-dark}" || true

echo "== Removendo arquivos"
rm -rf -- "$data/plasma/desktoptheme/breeze-by-4nrry" "$data/icons/Papirus-Dark-Pink"
rm -f -- "$data/konsole/Breeze-by-4nrry.colorscheme" "$data/konsole/Breeze-by-4nrry.profile"
if [ -f "$state/ghostty-config.ghostty.orig" ]; then
    cp "$state/ghostty-config.ghostty.orig" "$conf/ghostty/config.ghostty"
elif [ -f "$conf/ghostty/config.ghostty" ] && grep -q 'Breeze by 4nrry' "$conf/ghostty/config.ghostty"; then
    rm -f -- "$conf/ghostty/config.ghostty"
fi
rm -rf -- "$state"

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
systemctl --user restart plasma-plasmashell.service 2>/dev/null || true
echo "Pronto. Reabra os terminais para voltarem ao normal."
