# Zen Browser com blur de verdade

Opcional. O blur de verdade vem do **Better Blur DX**: rode `./install.sh --zen` para forçar blur nas janelas de classe `zen`.
Falta só deixar o Zen transparente com o mod abaixo.

## Mod: Transparent Zen (sameerasw)

Instale em **Configurações → Zen Mods** → procure **Transparent Zen** (<https://www.sameerasw.com/zen>).
Ajustes usados, nas opções do mod:

| Opção | Valor |
|---|---|
| Transparency color | `#20232633` (cinza do Breeze a 20%) |
| Allow transparency | **desligado** (ligado, sites de fundo branco ficam quebrados) |
| Transparency on Linux | **ligado** |
| Background image | **desligado** (o fundo é o blur do Better Blur DX) |
| Light tint | Flip |
| Transparent sidebar / glance | ligados |
| No shadow | ligado |

As mesmas opções, como ficam no `about:config`:

```
mod.sameerasw.zen_transparency_color = #20232633
mod.sameerasw.zen_bg_color_enabled = true
mod.sameerasw.zen_bg_img_enabled = false
mod.sameerasw.zen_no_shadow = true
mod.sameerasw.zen_transparent_sidebar_enabled = true
mod.sameerasw.zen_transparent_glance_enabled = true
mod.sameerasw_zen_light_tint = 1
zen.widget.linux.transparency = true
```

## Outros mods instalados aqui (opcionais)

Floating Status Bar, Bleeding Corners Fix, Better Find Bar (`theme.better_find_bar.transparent_background = true`),
Audio Indicator Enhanced, Ghost Tabs.
