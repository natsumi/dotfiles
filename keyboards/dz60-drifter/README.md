# DZ60

# Specs
* PCB: DZ60 Rev 3
* Case: KBDFans Black Alu 5 Degree 60% Case
* Switches: Zealios V2 Switches (62g)
* Stablizers: GMK Stabilizers
* Keycaps: DSA Drifters Keycaps
* Port: USB-C
* Microcontroller: amtmeg32u4

# Configuration
* QMK Configurator: https://config.qmk.fm/#/dz60/LAYOUT_60_ansi
# Flashing QMK
* QMK Toolbox: https://github.com/qmk/qmk_toolbox

```sh
  brew tap homebrew/cask-drivers
  brew cask install qmk-toolbox
  ```

  1.  Put KB in flash mode `fn+\`
  2.  Hit `Open` and select firmware `dz60_drifter.hex`
  3.  Hit `flash`

# QMK Useful Links
* Custom Layer Guide:  https://jayliu50.github.io/qmk-cheatsheet/#layers
* Bootmagic Settings: https://beta.docs.qmk.fm/features/feature_bootmagic
* Keyboard Tester: https://www.keyboardtester.com/
