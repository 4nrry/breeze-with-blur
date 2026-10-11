#!/usr/bin/env bash
# Breeze with Blur — instala o visual no usuário atual (KDE Plasma 6, Wayland).
# Não usa sudo (o Better Blur DX é instalado antes, por ./better-blur-dx.sh). Guarda os valores antigos em ~/.local/share/breeze-with-blur/backup.ini
# para o uninstall.sh restaurar.
set -euo pipefail

# Uso: ./install.sh [--zen]
#   --zen  também força o blur nas janelas do Zen Browser (precisa do mod Transparent Zen; ver zen/README.md)
zen=0
for arg in "$@"; do
    case "$arg" in
        --zen) zen=1 ;;
        -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
        *) echo "opção desconhecida: $arg (use --zen ou --help)" >&2; exit 1 ;;
    esac
done

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
conf="${XDG_CONFIG_HOME:-$HOME/.config}"
state="$data/breeze-with-blur"
backup="$state/backup.ini"

need() { command -v "$1" >/dev/null || { echo "falta o comando: $1" >&2; exit 1; }; }
need kwriteconfig6
need kreadconfig6
need plasma-apply-desktoptheme

# O Better Blur DX é obrigatório (substitui o blur do KWin). Compile antes com ./better-blur-dx.sh
bbdx=""
for so in /usr/lib/*/qt6/plugins/kwin/effects/plugins/better_blur_dx.so /usr/lib/qt6/plugins/kwin/effects/plugins/better_blur_dx.so; do
    [ -e "$so" ] && bbdx="$so"
done
if [ -z "$bbdx" ]; then
    echo "Better Blur DX não está instalado. Rode primeiro:  ./better-blur-dx.sh" >&2
    exit 1
fi

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
rm -rf -- "$data/plasma/desktoptheme/breeze-with-blur"
cp -r "$repo/plasma/breeze-with-blur" "$data/plasma/desktoptheme/"
remember plasmarc Theme name
plasma-apply-desktoptheme breeze-with-blur

echo "== Painel translúcido"
# panelOpacity fica em [PlasmaViews][Panel N]; 2 = translúcido. Aplica em todos os painéis existentes.
while IFS= read -r panel; do
    set_key plasmashellrc "PlasmaViews>$panel" panelOpacity 2
done < <(sed -n 's/^\[PlasmaViews\]\[\(Panel [0-9]*\)\]$/\1/p' "$conf/plasmashellrc" 2>/dev/null || true)

echo "== Menus dos apps a 20% (estilo Breeze)"
set_key breezerc Style MenuOpacity 20

echo "== Better Blur DX no lugar do blur do KWin (os dois juntos conflitam) + translucidez"
set_key kwinrc Plugins blurEnabled false
set_key kwinrc Plugins better_blur_dxEnabled true
set_key kwinrc Plugins translucencyEnabled true
# Painel, menus e terminais já pedem blur sozinhos. Forçar blur no Zen é opcional (--zen).
set_key kwinrc Effect-better-blur-dx BlurMatching true
set_key kwinrc Effect-better-blur-dx BlurNonMatching false
if [ "$zen" -eq 1 ]; then
    echo "== Zen: force blur nas janelas de classe zen"
    remember kwinrc Effect-better-blur-dx WindowClasses
    classes="$(kreadconfig6 --file kwinrc --group Effect-better-blur-dx --key WindowClasses)"
    if ! printf '%s\n' "$classes" | grep -qx zen; then
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key WindowClasses "$(printf '%s\nzen' "$classes" | sed '/^$/d')"
    fi
fi

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
cp "$repo/konsole/Breeze-with-blur.colorscheme" "$repo/konsole/Breeze-with-blur.profile" "$data/konsole/"
set_key konsolerc "Desktop Entry" DefaultProfile Breeze-with-blur.profile
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
[ "$zen" -eq 1 ] && echo "Zen: instale o mod Transparent Zen e ajuste como em zen/README.md, depois reinicie o Zen."
true
