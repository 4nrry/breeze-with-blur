# Breeze with blur

O visual **Breeze by 4nrry** para KDE Plasma 6: o Breeze Escuro de sempre, só com vidro (blur) onde ele fica bonito.
Nada de tema da loja, nada de estilo de app trocado — é uma cópia local do Breeze com algumas opacidades editadas.

- **Painel, popups, dicas e menus** translúcidos a 20% com o blur nativo do KWin
- **Konsole, Yakuake e Ghostty** com fundo `#202326` a 20% + blur
- **Ícones Papirus-Dark** com pastas rosa (inclusive nos tamanhos grandes do Dolphin)
- Opcional: **Zen Browser** com blur de verdade (Better Blur DX) — ver [`zen/`](zen/README.md) e [`kwin/`](kwin/better-blur-dx.md)

A cor base em todo lugar é o cinza do Breeze, `#202326`, a 20% (`#20232633`).

Testado no Kubuntu 26.04, Plasma 6.6.6, Wayland.

## Instalar

```bash
sudo apt install papirus-icon-theme
git clone https://github.com/4nrry/breeze-with-blur
cd breeze-with-blur
./install.sh
```

O `install.sh` não usa sudo e só mexe no usuário atual. Ele:

| O quê | Onde |
|---|---|
| Estilo do Plasma `breeze-by-4nrry` (painel 20%, popups 20%, dicas 20%, contorno 12%) | `~/.local/share/plasma/desktoptheme/` |
| Painel no modo translúcido | `plasmashellrc` → `panelOpacity=2` |
| Menus dos apps a 20% | `breezerc` → `MenuOpacity=20` |
| Blur nativo + Translucidez ligados, sem ruído | `kwinrc` |
| Ícones `Papirus-Dark-Pink` (tema que só tem links para o Papirus instalado) | `~/.local/share/icons/` |
| Perfil "Breeze by 4nrry" do Konsole (padrão; o Yakuake usa o mesmo) | `~/.local/share/konsole/`, `konsolerc` |
| Moldura do Yakuake translúcida | `yakuakerc` |
| Ghostty: tema Breeze, fundo `#202326`, opacidade 0.2, blur | `~/.config/ghostty/config.ghostty` |

Os valores antigos ficam guardados em `~/.local/share/breeze-by-4nrry/backup.ini`.
Rodar de novo é seguro (não sobrescreve o backup).

Depois de instalar, **reabra o Konsole/Yakuake/Ghostty**. Se o painel ficar opaco, reinicie o plasmashell:

```bash
systemctl --user restart plasma-plasmashell.service
```

## Desinstalar

```bash
./uninstall.sh
```

Restaura cada configuração do backup e apaga os arquivos instalados. O pacote `papirus-icon-theme` fica (remova com apt se quiser).

## Extras manuais

- **Destaque rosa**: aqui a cor de destaque vem do papel de parede (Configurações → Cores → "Do papel de parede").
  Com outro papel de parede a cor muda — isso é esperado.
- **Tela de login (SDDM)** com o papel de parede: Configurações → Tela de login (SDDM) → Breeze → escolha a imagem →
  "Aplicar configurações do Plasma". Precisa da senha de administrador.
- **Zen Browser**: [`zen/README.md`](zen/README.md).
- **Blur de verdade no Zen**: [`kwin/better-blur-dx.md`](kwin/better-blur-dx.md) (efeito compilado; recompilar a cada atualização do Plasma).

## Instalar com o Claude

Abra o Claude Code dentro da pasta clonada e cole o conteúdo de [`PROMPT.md`](PROMPT.md).

## Créditos e licença

O Estilo do Plasma em `plasma/` é uma cópia do Breeze Escuro do [KDE Visual Design Group](https://invent.kde.org/plasma/libplasma),
com opacidades editadas, e segue a licença dele (LGPL). Os ícones são links para o
[Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) (GPL-3.0) instalado pelo apt; nenhum ícone é redistribuído aqui.
Scripts e configurações: livres para usar.
