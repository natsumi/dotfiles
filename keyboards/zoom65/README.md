# [Zoom65](https://zoom65.com)

![Cover Image](cover.jpg)

# Specs

- Case: Meletrix Zoom65 ($180)
- Plate: Acrylic
- Switches: Gateron Ink Black V2 ($84)
  - Linear: Actuation 60g Bottom 70g
  - NovelKey Deskeys Filmi
  - Switch Lube: Krytox 250g0
  - Spring Lube: 105 GPL
  - Stablizer Lube: Krytox 205g0
- Keycaps: GMK Olivia
- PCB: Gasket Mounted
- Port: USB-C
- Microcontroller: amtmeg32u4
- Firmwre: QMK

# Layout

## OSX Layer 0

  - To switch to this layer use `Fn + <`

![Layer 0](layer0.png)

## Windows Layer 1

  - To switch to this layer use `Fn + >`
  - This just swaps the Windows and Alt key

![Layer 1](layer1.png)

## Function Layer 2

![Layer 2](layer2.png)

# Configuration

- [QMK Configurator](https://config.qmk.fm/#/meletrix/zoom65/LAYOUT_65_ansi_blocker)

# Flashing QMK

- [QMK Toolbox](https://github.com/qmk/qmk_toolbox)

1.  Put KB in DFU flash mode
  - If using the custom layout use:  `Fn + \`
  - Default mode use `Fn + End`
2.  Hit `Open` and select firmware `zoom65.hex`
3.  Hit `flash`

# Links

- [Zoom65](https://zoom65.com)
- [Meletrix Zoom65](https://meletrix.com/products/zoom65)
- [Custom Layer Guide](https://jayliu50.github.io/qmk-cheatsheet/#layers)
- [Bootmagic Settings](https://beta.docs.qmk.fm/features/feature_bootmagic)
- [Keyboard Tester](https://www.keyboardtester.com/)
