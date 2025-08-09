#!/usr/bin/env -S guix shell dfu-programmer -- sh

set -e
FIRMWARE=$(guix build -f guix.scm)/sarg_default.hex
test -r $FIRMWARE

dfu-programmer atmega32u4 erase
dfu-programmer atmega32u4 flash $FIRMWARE
dfu-programmer atmega32u4 launch
