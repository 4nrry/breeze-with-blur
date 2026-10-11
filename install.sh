#!/usr/bin/env bash
# Breeze by 4nrry — instala o visual no usuário atual (KDE Plasma 6, Wayland).
# Não usa sudo. Guarda os valores antigos em ~/.local/share/breeze-by-4nrry/backup.ini
# para o uninstall.sh restaurar.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
conf="${XDG_CONFIG_HOME:-$HOME/.config}"
state="$data/breeze-by-4nrry"
backup="$state/backup.ini"

need() { command -v "$1" >/dev/null || { echo "falta o comando: $1" >&2; exit 1; }; }
need kwriteconfig6
need kreadconfig6
need plasma-apply-desktoptheme

mkdir -p "$state"

# Grava "arquivo|grupo[>subgrupo]|chave=valor-antigo" uma única vez (rodar de novo não sobrescreve o backup).
groups() { local IFS='>'; for g in $1; do printf -- '--group\0%s\0' "$g"; done; }
remember() {
    local file="$1" group="$2" key="$3" old args=()
    grep -qF "$file|$group|$key=" "$backup" 2>/dev/null && return 0
    while IFS= read -r -d '' a; do args+=("$a"); done < <(groups "$group")
    old="$(kreadconfig6 --file "$file" "${args[@]}" --key "$key")"
    printf '%s|%s|%s=%s\n' "$file" "$group" "$key" "$old" >> "$backup"
}
set_key() {
    local args=()
    remember "$1" "$2" "$3"
    while IFS= read -r -d '' a; do args+=("$a"); done < <(groups "$2")
    kwriteconfig6 --file "$1" "${args[@]}" --key "$3" "$4"
}

echo "== Estilo do Plasma (painel, popups e dicas translúcidos)"
mkdir -p "$data/plasma/desktoptheme"
rm -rf -- "$data/plasma/desktoptheme/breeze-by-4nrry"
cp -r "$repo/plasma/breeze-by-4nrry" "$data/plasma/desktoptheme/"
remember plasmarc Theme name
plasma-apply-desktoptheme breeze-by-4nrry

echo "== Painel translúcido"
# panelOpacity fica em [PlasmaViews][Panel N]; 2 = translúcido. Aplica em todos os painéis existentes.
while IFS= read -r panel; do
    set_key plasmashellrc "PlasmaViews>$panel" panelOpacity 2
done < <(sed -n 's/^\[PlasmaViews\]\[\(Panel [0-9]*\)\]$/\1/p' "$conf/plasmashellrc" 2>/dev/null || true)

echo "== Menus dos apps a 20% (estilo Breeze)"
set_key breezerc Style MenuOpacity 20

echo "== Blur nativo do KWin + translucidez"
set_key kwinrc Plugins blurEnabled true
set_key kwinrc Plugins translucencyEnabled true
set_key kwinrc Effect-blur NoiseStrength 0

echo "== Ícones Papirus-Dark com pastas rosa"
if [ -d /usr/share/icons/Papirus ]; then
    dst="$data/icons/Papirus-Dark-Pink"
    rm -rf -- "$dst"
    mkdir -p "$dst"
    cp "$repo/icons/Papirus-Dark-Pink/index.theme" "$dst/"
    while IFS=$'\t' read -r link target; do
        mkdir -p "$dst/$(dirname "$link")"
        ln -sfn "$target" "$dst/$link"
    done < "$repo/icons/Papirus-Dark-Pink/links.tsv"
    remember kdeglobals Icons Theme
    changeicons="$(ls /usr/lib/*/libexec/plasma-changeicons /usr/libexec/plasma-changeicons 2>/dev/null | head -1 || true)"
    if [ -n "$changeicons" ]; then "$changeicons" Papirus-Dark-Pink; else kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark-Pink; fi
else
    echo "   pulado: instale antes com  sudo apt install papirus-icon-theme  e rode de novo"
fi

echo "== Konsole e Yakuake (#202326 a 20% + blur)"
mkdir -p "$data/konsole"
cp "$repo/konsole/Breeze-by-4nrry.colorscheme" "$repo/konsole/Breeze-by-4nrry.profile" "$data/konsole/"
set_key konsolerc "Desktop Entry" DefaultProfile Breeze-by-4nrry.profile
set_key yakuakerc Appearance Translucency true
set_key yakuakerc Appearance BackgroundColor 32,35,38
set_key yakuakerc Appearance BackgroundColorOpacity 20

echo "== Ghostty"
if command -v ghostty >/dev/null; then
    mkdir -p "$conf/ghostty"
    for f in config.ghostty config; do
        [ -e "$conf/ghostty/$f" ] && [ ! -e "$state/ghostty-$f.orig" ] && cp "$conf/ghostty/$f" "$state/ghostty-$f.orig"
    done
    cp "$repo/ghostty/config.ghostty" "$conf/ghostty/config.ghostty"
else
    echo "   pulado: Ghostty não está instalado"
fi

echo "== Recarregando"
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
# Trocar o efeito de blur deixa painel e KRunner opacos até o plasmashell reiniciar
systemctl --user restart plasma-plasmashell.service 2>/dev/null || { kquitapp6 plasmashell >/dev/null 2>&1 || true; (setsid plasmashell >/dev/null 2>&1 &); }

echo
echo "Pronto. Backup dos valores antigos: $backup"
echo "Abra de novo o Konsole/Ghostty para ver os terminais novos."
