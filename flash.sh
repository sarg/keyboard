#!/usr/bin/env -S guix shell dfu-programmer -- sh
dfu-programmer atmega32u4 erase
dfu-programmer atmega32u4 flash $(guix build -f guix.scm)/sarg_default.hex
dfu-programmer atmega32u4 launch
