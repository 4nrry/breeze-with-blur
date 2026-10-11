# Better Blur DX (opcional, só para o Zen)

O blur nativo do KWin só funciona em apps que pedem blur (Konsole, Yakuake, Ghostty, painel, menus).
Para o **Zen** ganhar blur de verdade é preciso o efeito [Better Blur DX](https://github.com/xarblu/kwin-effects-better-blur-dx),
que **força** o blur em janelas escolhidas.

> Custo: é compilado a partir do código-fonte e **precisa ser recompilado a cada atualização do KWin/Plasma**
> (senão some da lista de efeitos). Sem ele, o resto do tema funciona normalmente.

## Instalar (Kubuntu, Wayland) — passos do README do projeto

```bash
sudo apt install -y git cmake g++ extra-cmake-modules qt6-tools-dev kwin-dev libkf6configwidgets-dev gettext libkf6crash-dev libkf6globalaccel-dev libkf6kio-dev libkf6service-dev libkf6notifications-dev libkf6kcmutils-dev libkdecorations3-dev libxcb-composite0-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-res0-dev libxcb-sync-dev
git clone https://github.com/xarblu/kwin-effects-better-blur-dx ~/src/kwin-effects-better-blur-dx
cd ~/src/kwin-effects-better-blur-dx && ./build.sh
```

Depois:

1. **Configurações → Efeitos da área de trabalho**: desligue **Blur** e ligue **Better Blur DX** (os dois juntos conflitam).
2. Nas opções do Better Blur DX → Force blur: classes de janela `zen`, modo **Blur only matching**.
3. Reinicie o plasmashell, senão painel e KRunner ficam opacos:
   `systemctl --user restart plasma-plasmashell.service`

Testado aqui no commit `3d8c1a8` (Plasma 6.6.6).

## Depois de atualizar o Plasma

```bash
cd ~/src/kwin-effects-better-blur-dx && git pull && ./build.sh
```
e saia/entre na sessão.

## O que não funcionou (para não repetir)

- Esquema de cores transparente com o estilo Breeze para blur no Dolphin/apps KDE: só a barra de título fica
  transparente (bug KDE [480608](https://bugs.kde.org/show_bug.cgi?id=480608)).
- Discord/Vesktop transparente: cada tela (popups, configurações) precisa de CSS à mão. Não vale a pena.
