# Prompt para o Claude Code

Cole o texto abaixo no Claude Code aberto **dentro da pasta do repositório clonado** (`breeze-with-blur`).

---

Quero aplicar no meu KDE Plasma o visual deste repositório (Breeze with blur). Leia o `README.md`, o `install.sh`
e o `uninstall.sh` inteiros antes de fazer qualquer coisa, e siga este roteiro:

1. **Confira o ambiente** e me diga o que encontrou: versão do Plasma (`plasmashell --version`), sessão
   (`echo $XDG_SESSION_TYPE`), se `kwriteconfig6`, `plasma-apply-desktoptheme` e `/usr/share/icons/Papirus` existem,
   e se Konsole, Yakuake e Ghostty estão instalados. O repositório foi testado no Plasma 6.6 em Wayland; se o meu for
   bem diferente (Plasma 5, X11), me avise antes de continuar.
2. **Mostre o que vai mudar**: rode `kreadconfig6` para cada chave que o `install.sh` altera e me mostre o valor
   atual ao lado do novo. Se eu já tiver um `~/.config/ghostty/config.ghostty` próprio, me mostre o conteúdo e
   pergunte se posso substituir (o script guarda uma cópia).
3. Se faltar o Papirus, me passe o comando `sudo apt install papirus-icon-theme` para eu rodar no terminal
   (não rode sudo por mim).
4. **Better Blur DX** (obrigatório): leia o `better-blur-dx.sh` e me explique o que ele faz e o custo (instala
   dependências de compilação e precisa ser rodado de novo a cada atualização do Plasma). Ele pede a senha de
   administrador, então me passe `./better-blur-dx.sh` para eu rodar no terminal. Depois confira que existe
   `better_blur_dx.so` em `/usr/lib/*/qt6/plugins/kwin/effects/plugins/`.
5. Pergunte se eu uso o **Zen Browser**. Tudo do Zen é opcional: só se eu disser que sim, use `--zen`.
   Com a minha confirmação, rode `./install.sh` (ou `./install.sh --zen`) e me mostre a saída.
6. **Verifique** sem depender de olho: `kreadconfig6 --file plasmarc --group Theme --key name` deve dar
   `breeze-with-blur`, `kreadconfig6 --file kdeglobals --group Icons --key Theme` deve dar `Papirus-Dark-Pink`,
   `find ~/.local/share/icons/Papirus-Dark-Pink -xtype l | wc -l` deve dar `0` (nenhum link quebrado),
   `kreadconfig6 --file kwinrc --group Plugins --key better_blur_dxEnabled` deve dar `true` e
   `blurEnabled` deve dar `false`.
7. Me peça para reabrir o Konsole/Ghostty e olhar o painel. Se o painel ou o KRunner estiverem opacos, reinicie
   com `systemctl --user restart plasma-plasmashell.service`.
8. **Zen Browser** (só se eu usar): me guie pelo `zen/README.md` (instalar o mod Transparent Zen e ajustar as
   opções). Para eu ver o blur, saia e entre na sessão ou reinicie o Zen depois do install.

Se algo der errado ou eu não gostar, rode `./uninstall.sh`, que restaura tudo pelo backup.
