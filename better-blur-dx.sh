#!/usr/bin/env bash
# Compila e instala o efeito Better Blur DX (https://github.com/xarblu/kwin-effects-better-blur-dx).
# Pede a senha de administrador (apt e make install). Rode de novo depois de cada atualização do Plasma/KWin:
# o efeito é compilado contra a versão instalada do KWin e some da lista quando ela muda.
set -euo pipefail

src="${BBDX_SRC:-$HOME/src/kwin-effects-better-blur-dx}"

if [ "${XDG_SESSION_TYPE:-}" = "x11" ]; then
    echo "Sessão X11 detectada. Este script é para Wayland; veja o README do Better Blur DX para X11." >&2
    exit 1
fi

echo "== Dependências de compilação (apt)"
sudo apt install -y git cmake g++ extra-cmake-modules qt6-tools-dev kwin-dev libkf6configwidgets-dev gettext \
    libkf6crash-dev libkf6globalaccel-dev libkf6kio-dev libkf6service-dev libkf6notifications-dev \
    libkf6kcmutils-dev libkdecorations3-dev libxcb-composite0-dev libxcb-randr0-dev libxcb-shm0-dev \
    libxcb-res0-dev libxcb-sync-dev libdrm-dev

echo "== Código-fonte em $src"
if [ -d "$src/.git" ]; then
    git -C "$src" pull --ff-only
else
    mkdir -p "$(dirname "$src")"
    git clone https://github.com/xarblu/kwin-effects-better-blur-dx "$src"
fi

echo "== Compilando e instalando"
(cd "$src" && ./build.sh)

echo
echo "Better Blur DX instalado. Agora rode ./install.sh (ou, se já rodou, saia e entre na sessão)."
