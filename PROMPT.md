# Prompt para o Claude Code

Cole o texto abaixo no Claude Code aberto **dentro da pasta do repositório clonado** (`breeze-with-blur`).

---

Quero aplicar no meu KDE Plasma o visual deste repositório (Breeze with Blur). Leia o `README.md`, o `install.sh`,
o `uninstall.sh` e o `better-blur-dx.sh` inteiros antes de fazer qualquer coisa, e siga este roteiro:

1. **Confira o ambiente** e me diga o que encontrou: versão do Plasma (`plasmashell --version`), sessão
   (`echo $XDG_SESSION_TYPE`), se `kwriteconfig6`, `plasma-apply-desktoptheme` e `plasma-apply-colorscheme` existem,
   se o Papirus está instalado (`/usr/share/icons/Papirus-Dark`), e quais destes estão instalados: Konsole, Yakuake,
   Ghostty, Zen Browser. O repositório foi testado no Plasma 6.6 em Wayland; se o meu for bem diferente
   (Plasma 5, X11), me avise antes de continuar.
2. **Opcionais**: me pergunte quais destes eu quero e monte as opções do `install.sh` com as respostas:
   ícones Papirus com pastas rosa (`--icons`), Konsole (`--konsole`), Yakuake (`--yakuake`), Ghostty (`--ghostty`)
   e Zen Browser (`--zen`). Só ofereça os terminais e o Zen que estiverem instalados.
3. **Mostre o que vai mudar**: rode `kreadconfig6` para cada chave que o `install.sh` vai alterar com essas opções
   e me mostre o valor atual ao lado do novo. Se eu escolher `--ghostty` e já tiver um
   `~/.config/ghostty/config.ghostty`, me mostre o conteúdo e pergunte se posso substituir (o script guarda uma cópia).
4. **Pré-requisitos com sudo** (não rode sudo por mim; me passe os comandos para eu rodar no terminal):
   - **Better Blur DX** (obrigatório): me explique o que o `better-blur-dx.sh` faz e o custo (instala dependências de
     compilação e precisa ser rodado de novo a cada atualização do Plasma). Depois de eu rodar `./better-blur-dx.sh`,
     confira que existe `better_blur_dx.so` em `/usr/lib/*/qt6/plugins/kwin/effects/plugins/`.
   - Só se eu quiser os ícones e faltar o Papirus: `sudo apt install papirus-icon-theme`.
5. Com a minha confirmação, rode `./install.sh` com as opções escolhidas e me mostre a saída.
6. **Verifique** sem depender de olho:
   - `kreadconfig6 --file plasmarc --group Theme --key name` → `breeze-with-blur`
   - `kreadconfig6 --file kwinrc --group Plugins --key better_blur_dxEnabled` → `true`, e `blurEnabled` → `false`
   - `kreadconfig6 --file kwinrc --group Plugins --key magiclampEnabled` → `true`
   - com `--icons`: `kreadconfig6 --file kdeglobals --group Icons --key Theme` → `Papirus-Dark-Pink` e
     `find ~/.local/share/icons/Papirus-Dark-Pink -xtype l | wc -l` → `0` (nenhum link quebrado)
   - com `--konsole`/`--yakuake`: `kreadconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile`
     → `Breeze-with-blur.profile`
7. Me peça para sair e entrar na sessão, reabrir os terminais e olhar o painel. Se o painel ou o KRunner estiverem
   opacos, reinicie com `systemctl --user restart plasma-plasmashell.service`.
8. **Zen Browser** (só se eu escolhi `--zen`): me guie pelo `zen/README.md` (instalar o mod Transparent Zen e ajustar
   as opções), depois reinicie o Zen.

Se algo der errado ou eu não gostar, rode `./uninstall.sh`, que restaura tudo pelo backup.
