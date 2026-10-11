# Breeze with Blur

O visual **Breeze with Blur** para KDE Plasma 6: o Breeze Escuro de sempre, só com vidro (blur) onde ele fica bonito.
Nada de tema da loja, nada de estilo de app trocado — é uma cópia local do Breeze com algumas opacidades editadas.

- **Painel, popups, dicas e menus** translúcidos a 20% com blur
- Blur pelo efeito [Better Blur DX](https://github.com/xarblu/kwin-effects-better-blur-dx), que também consegue forçar blur em apps que não pedem
- Opcionais: **ícones Papirus-Dark** com pastas rosa, **Konsole / Yakuake / Ghostty** com fundo `#202326` a 20% + blur,
  e **Zen Browser** com blur de verdade

A cor base em todo lugar é o cinza do Breeze, `#202326`, a 20% (`#20232633`).

Testado no Kubuntu 26.04, Plasma 6.6.6, Wayland.

## Instalar

```bash
git clone https://github.com/4nrry/breeze-with-blur
cd breeze-with-blur
./better-blur-dx.sh                    # obrigatório: compila e instala o Better Blur DX (pede a senha de administrador)
sudo apt install papirus-icon-theme    # só se for usar --icons
./install.sh --icons --konsole         # escolha as opções abaixo
```

| Opção | O que acrescenta |
|---|---|
| *(nenhuma)* | só o visual do sistema (tabela abaixo) |
| `--icons` | ícones `Papirus-Dark-Pink`: Papirus-Dark com pastas rosa, inclusive nos tamanhos grandes do Dolphin |
| `--konsole` | perfil "Breeze with Blur" como padrão do Konsole |
| `--yakuake` | o mesmo perfil (o Yakuake usa o perfil padrão do Konsole) + moldura translúcida |
| `--ghostty` | `~/.config/ghostty/config.ghostty` com tema Breeze, fundo `#202326`, opacidade 0.2 e blur (guarda uma cópia do seu) |
| `--zen` | force blur nas janelas `zen` (soma à lista que já existir); o mod do Zen é manual, ver [`zen/`](zen/README.md) |

O `better-blur-dx.sh` instala as dependências de compilação pelo apt, baixa o código em `~/src/kwin-effects-better-blur-dx`
e roda o `build.sh` do projeto. **Rode de novo depois de cada atualização do Plasma** — o efeito é compilado para a versão
instalada do KWin e some da lista de efeitos quando ela muda.

O `install.sh` não usa sudo e só mexe no usuário atual. Ele para com um aviso se faltar o Better Blur DX
(ou o Papirus, com `--icons`). Sem opções, ele aplica:

| O quê | Onde |
|---|---|
| Esquema de cores Breeze Escuro, cor de destaque tirada do papel de parede | `kdeglobals` |
| Estilo dos apps e decoração das janelas Breeze (contorno e cantos arredondados ligados) | `kdeglobals`, `kwinrc`, `breezerc` |
| Menus dos apps a 20% | `breezerc` → `MenuOpacity=20` |
| Estilo do Plasma `breeze-with-blur` (painel 20%, popups 20%, dicas 20%, contorno 12%) | `~/.local/share/plasma/desktoptheme/` |
| Painel no modo translúcido | `plasmashellrc` → `panelOpacity=2` |
| Better Blur DX no lugar do blur do KWin (força 15, ruído 5, saturação 150), Translucidez ligada | `kwinrc` |
| Animação de minimizar Lâmpada mágica | `kwinrc` |

Os valores antigos ficam guardados em `~/.local/share/breeze-with-blur/backup.ini`.
Rodar de novo é seguro (não sobrescreve o backup).

Depois de instalar, **saia e entre na sessão** e reabra os terminais. Se o painel ficar opaco, reinicie o plasmashell:

```bash
systemctl --user restart plasma-plasmashell.service
```

**Não vem junto** (é gosto pessoal, não do tema): fontes, papel de parede, tela de bloqueio, Luz noturna e atalhos.

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
