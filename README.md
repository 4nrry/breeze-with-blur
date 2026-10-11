# Breeze with blur

O visual **Breeze with blur** para KDE Plasma 6: o Breeze Escuro de sempre, só com vidro (blur) onde ele fica bonito.
Nada de tema da loja, nada de estilo de app trocado — é uma cópia local do Breeze com algumas opacidades editadas.

- **Painel, popups, dicas e menus** translúcidos a 20% com blur
- **Konsole, Yakuake e Ghostty** com fundo `#202326` a 20% + blur
- **Ícones Papirus-Dark** com pastas rosa (inclusive nos tamanhos grandes do Dolphin)
- Blur pelo efeito [Better Blur DX](https://github.com/xarblu/kwin-effects-better-blur-dx), que também consegue forçar blur em apps que não pedem
- Opcional: **Zen Browser** com blur de verdade (`./install.sh --zen`) — ver [`zen/`](zen/README.md)

A cor base em todo lugar é o cinza do Breeze, `#202326`, a 20% (`#20232633`).

Testado no Kubuntu 26.04, Plasma 6.6.6, Wayland.

## Instalar

```bash
sudo apt install papirus-icon-theme
git clone https://github.com/4nrry/breeze-with-blur
cd breeze-with-blur
./better-blur-dx.sh   # compila e instala o Better Blur DX (pede a senha de administrador)
./install.sh          # ou ./install.sh --zen se usar o Zen Browser
```

O `better-blur-dx.sh` instala as dependências de compilação pelo apt, baixa o código em `~/src/kwin-effects-better-blur-dx`
e roda o `build.sh` do projeto. **Rode de novo depois de cada atualização do Plasma** — o efeito é compilado para a versão
instalada do KWin e some da lista de efeitos quando ela muda.

O `install.sh` não usa sudo e só mexe no usuário atual (ele para com um aviso se o Better Blur DX não estiver instalado). Ele:

| O quê | Onde |
|---|---|
| Estilo do Plasma `breeze-with-blur` (painel 20%, popups 20%, dicas 20%, contorno 12%) | `~/.local/share/plasma/desktoptheme/` |
| Painel no modo translúcido | `plasmashellrc` → `panelOpacity=2` |
| Menus dos apps a 20% | `breezerc` → `MenuOpacity=20` |
| Better Blur DX ligado no lugar do blur do KWin, Translucidez ligada | `kwinrc` |
| Só com `--zen`: force blur nas janelas `zen` (soma à lista que já existir) | `kwinrc` |
| Ícones `Papirus-Dark-Pink` (tema que só tem links para o Papirus instalado) | `~/.local/share/icons/` |
| Perfil "Breeze with blur" do Konsole (padrão; o Yakuake usa o mesmo) | `~/.local/share/konsole/`, `konsolerc` |
| Moldura do Yakuake translúcida | `yakuakerc` |
| Ghostty: tema Breeze, fundo `#202326`, opacidade 0.2, blur | `~/.config/ghostty/config.ghostty` |

Os valores antigos ficam guardados em `~/.local/share/breeze-with-blur/backup.ini`.
Rodar de novo é seguro (não sobrescreve o backup).

Depois de instalar, **reabra o Konsole/Yakuake/Ghostty**. Se o painel ficar opaco, reinicie o plasmashell:

```bash
systemctl --user restart plasma-plasmashell.service
```

## Desinstalar

```bash
./uninstall.sh
```

Restaura cada configuração do backup (volta o blur do KWin) e apaga os arquivos instalados.
O pacote `papirus-icon-theme` e o Better Blur DX ficam instalados. Para remover o efeito:

```bash
cd ~/src/kwin-effects-better-blur-dx && xargs -d '\n' sudo rm -f -- < build/install_manifest.txt
```

## Extras manuais

- **Destaque rosa**: aqui a cor de destaque vem do papel de parede (Configurações → Cores → "Do papel de parede").
  Com outro papel de parede a cor muda — isso é esperado.
- **Tela de login (SDDM)** com o papel de parede: Configurações → Tela de login (SDDM) → Breeze → escolha a imagem →
  "Aplicar configurações do Plasma". Precisa da senha de administrador.
- **Zen Browser**: [`zen/README.md`](zen/README.md).
- **Detalhes do Better Blur DX** e o que não funcionou: [`kwin/better-blur-dx.md`](kwin/better-blur-dx.md).

## Instalar com o Claude

Abra o Claude Code dentro da pasta clonada e cole o conteúdo de [`PROMPT.md`](PROMPT.md).

## Créditos e licença

O Estilo do Plasma em `plasma/` é uma cópia do Breeze Escuro do [KDE Visual Design Group](https://invent.kde.org/plasma/libplasma),
com opacidades editadas, e segue a licença dele (LGPL). Os ícones são links para o
[Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) (GPL-3.0) instalado pelo apt; nenhum ícone é redistribuído aqui.
Scripts e configurações: livres para usar.
