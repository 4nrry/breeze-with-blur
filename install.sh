#!/usr/bin/env bash
# Breeze with Blur — instala o visual no usuário atual (KDE Plasma 6, Wayland).
# Não usa sudo: o Better Blur DX (./better-blur-dx.sh) e o Papirus (apt) são instalados antes.
# Guarda os valores antigos em ~/.local/share/breeze-with-blur/backup.ini para o uninstall.sh restaurar.
#
# Uso: ./install.sh [--icons] [--konsole] [--yakuake] [--ghostty] [--zen]
#   sem opções  só o visual do sistema (estilo do Plasma, cores, decoração, menus, blur)
#   --icons     ícones Papirus-Dark com pastas rosa (precisa de: sudo apt install papirus-icon-theme)
#   --konsole   perfil "Breeze with Blur" no Konsole (fundo #202326 a 20% + blur)
#   --yakuake   o mesmo perfil no Yakuake (ele usa o perfil padrão do Konsole) + moldura translúcida
#   --ghostty   config do Ghostty (substitui ~/.config/ghostty/config.ghostty; guarda uma cópia)
#   --zen       força blur nas janelas do Zen Browser (precisa do mod Transparent Zen; ver zen/README.md)
set -euo pipefail

icons=0 konsole=0 yakuake=0 ghostty=0 zen=0
for arg in "$@"; do
    case "$arg" in
        --icons) icons=1 ;;
        --konsole) konsole=1 ;;
        --yakuake) yakuake=1 ;;
        --ghostty) ghostty=1 ;;
        --zen) zen=1 ;;
        -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "opção desconhecida: $arg (veja --help)" >&2; exit 1 ;;
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
need plasma-apply-colorscheme

# Pré-requisitos instalados com sudo, fora deste script
bbdx=""
for so in /usr/lib/*/qt6/plugins/kwin/effects/plugins/better_blur_dx.so /usr/lib/qt6/plugins/kwin/effects/plugins/better_blur_dx.so; do
    [ -e "$so" ] && bbdx="$so"
done
[ -n "$bbdx" ] || { echo "Better Blur DX não está instalado. Rode primeiro:  ./better-blur-dx.sh" >&2; exit 1; }
if [ "$icons" -eq 1 ] && [ ! -d /usr/share/icons/Papirus-Dark ]; then
    echo "Papirus não está instalado. Rode primeiro:  sudo apt install papirus-icon-theme" >&2; exit 1
fi
if [ "$konsole" -eq 1 ] || [ "$yakuake" -eq 1 ]; then command -v konsole >/dev/null || echo "aviso: Konsole não está instalado; o perfil fica pronto para quando estiver" >&2; fi
if [ "$yakuake" -eq 1 ]; then command -v yakuake >/dev/null || echo "aviso: Yakuake não está instalado" >&2; fi
if [ "$ghostty" -eq 1 ]; then command -v ghostty >/dev/null || echo "aviso: Ghostty não está instalado; a config fica pronta para quando estiver" >&2; fi

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

echo "== Esquema de cores Breeze Escuro, destaque tirado do papel de parede"
remember kdeglobals General ColorScheme
plasma-apply-colorscheme BreezeDark
set_key kdeglobals General accentColorFromWallpaper true

echo "== Estilo dos apps e decoração das janelas: Breeze"
set_key kdeglobals KDE widgetStyle Breeze
set_key kwinrc org.kde.kdecoration2 library org.kde.breeze
set_key kwinrc org.kde.kdecoration2 theme Breeze
set_key breezerc Common OutlineEnabled true
set_key breezerc Common RoundedCorners true

echo "== Menus dos apps a 20%"
set_key breezerc Style MenuOpacity 20

echo "== Estilo do Plasma Breeze with Blur (painel, popups e dicas a 20%, contorno 12%)"
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

echo "== Better Blur DX no lugar do blur do KWin (os dois juntos conflitam) + translucidez"
set_key kwinrc Plugins blurEnabled false
set_key kwinrc Plugins better_blur_dxEnabled true
set_key kwinrc Plugins translucencyEnabled true

echo "== Animação de minimizar: Lâmpada mágica (no lugar de Encolher)"
set_key kwinrc Plugins magiclampEnabled true
set_key kwinrc Plugins squashEnabled false
# Valores do Better Blur DX como estão no computador de origem (os padrões do efeito)
set_key kwinrc Effect-better-blur-dx BlurStrength 15
set_key kwinrc Effect-better-blur-dx NoiseStrength 5
set_key kwinrc Effect-better-blur-dx Brightness 100
set_key kwinrc Effect-better-blur-dx Saturation 150
set_key kwinrc Effect-better-blur-dx Contrast 100
set_key kwinrc Effect-better-blur-dx ForceContrastParams false
set_key kwinrc Effect-better-blur-dx CornerRadius 0
set_key kwinrc Effect-better-blur-dx BlurMatching true
set_key kwinrc Effect-better-blur-dx BlurNonMatching false

if [ "$icons" -eq 1 ]; then
    echo "== Ícones Papirus-Dark com pastas rosa"
    dst="$data/icons/Papirus-Dark-Pink"
    rm -rf -- "$dst"
    mkdir -p "$dst"
    cp "$repo/icons/Papirus-Dark-Pink/index.theme" "$dst/"
    while IFS=$'\t' read -r link target; do
        mkdir -p "$dst/$(dirname "$link")"
        ln -sfn "$target" "$dst/$link"
    done < "$repo/icons/Papirus-Dark-Pink/links.tsv"
    remember kdeglobals Icons Theme
    changeicons=""
    for c in /usr/lib/*/libexec/plasma-changeicons /usr/libexec/plasma-changeicons; do
        [ -x "$c" ] && changeicons="$c"
    done
    if [ -n "$changeicons" ]; then "$changeicons" Papirus-Dark-Pink; else kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark-Pink; fi
fi

if [ "$konsole" -eq 1 ] || [ "$yakuake" -eq 1 ]; then
    echo "== Perfil Breeze with Blur do Konsole (#202326 a 20% + blur)"
    mkdir -p "$data/konsole"
    cp "$repo/konsole/Breeze-with-blur.colorscheme" "$repo/konsole/Breeze-with-blur.profile" "$data/konsole/"
    set_key konsolerc "Desktop Entry" DefaultProfile Breeze-with-blur.profile
fi

if [ "$yakuake" -eq 1 ]; then
    echo "== Moldura do Yakuake translúcida"
    set_key yakuakerc Appearance Translucency true
    set_key yakuakerc Appearance BackgroundColor 32,35,38
    set_key yakuakerc Appearance BackgroundColorOpacity 20
fi

if [ "$ghostty" -eq 1 ]; then
    echo "== Ghostty (tema Breeze, fundo #202326 a 20% + blur)"
    mkdir -p "$conf/ghostty"
    if [ -e "$conf/ghostty/config.ghostty" ] && [ ! -e "$state/ghostty-config.ghostty.orig" ]; then
        cp "$conf/ghostty/config.ghostty" "$state/ghostty-config.ghostty.orig"
    fi
    cp "$repo/ghostty/config.ghostty" "$conf/ghostty/config.ghostty"
fi

if [ "$zen" -eq 1 ]; then
    echo "== Zen: force blur nas janelas de classe zen"
    remember kwinrc Effect-better-blur-dx WindowClasses
    classes="$(kreadconfig6 --file kwinrc --group Effect-better-blur-dx --key WindowClasses)"
    if ! printf '%s\n' "$classes" | grep -qx zen; then
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key WindowClasses "$(printf '%s\nzen' "$classes" | sed '/^$/d')"
    fi
fi

echo "== Recarregando"
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
# Trocar o efeito de blur deixa painel e KRunner opacos até o plasmashell reiniciar
systemctl --user restart plasma-plasmashell.service 2>/dev/null || { kquitapp6 plasmashell >/dev/null 2>&1 || true; (setsid plasmashell >/dev/null 2>&1 &); }

echo
echo "Pronto. Backup dos valores antigos: $backup"
echo "Saia e entre na sessão para todas as janelas pegarem a decoração e o blur novos."
if [ "$konsole" -eq 1 ] || [ "$yakuake" -eq 1 ] || [ "$ghostty" -eq 1 ]; then echo "Reabra os terminais para ver o fundo novo."; fi
if [ "$zen" -eq 1 ]; then echo "Zen: instale o mod Transparent Zen e ajuste como em zen/README.md, depois reinicie o Zen."; fi
