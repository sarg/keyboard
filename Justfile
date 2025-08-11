default:
	@just --list

stl:
	lein run
	openscad -o left.stl _left.scad
	openscad -o right.stl _right.scad

firmware:
	guix build -f guix.scm

svg: tangle
	which keymap || pip install keymap-drawer
	keymap draw <(keymap parse -q firmware/keymaps/default/keymap.json) > layout.svg

eeprom: tangle
	$(guix build -f qmk.scm)/bin/write_eeprom

tangle:
	#!/bin/sh
	emacs -Q --batch --eval "
	   (progn
		(require 'ob-tangle)
		(require 's)
		(require 'dash)

		(let ((org-confirm-babel-evaluate nil))
		  (find-file \"keymap.org\")
		  (search-forward \"helper\")
		  (org-babel-execute-src-block)
		  (org-babel-tangle)))"


flash: firmware
	#!/bin/sh
	set -euxo pipefail
	FIRMWARE=$(guix build -f guix.scm)/sarg_default.hex
	test -r $FIRMWARE

	dfu-programmer atmega32u4 flash --erase-first $FIRMWARE
	dfu-programmer atmega32u4 launch
