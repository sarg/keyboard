# show actions list
help:
	@just --list

# generate 3d models to print
stl:
	lein run
	openscad -o left.stl _left.scad
	openscad -o right.stl _right.scad

# build firmware
firmware:
	guix build -f guix.scm

# generate SVG layout printout
svg: tangle
	which keymap || pip install keymap-drawer
	keymap draw <(keymap parse -q firmware/keymaps/default/keymap.json) > layout.svg

# update keymap in eeprom
eeprom FULL='': tangle
	git diff write_eeprom/keymap.h > tmp
	sed '/^\+/s/NO }/true }/' <tmp >pt
	git checkout write_eeprom/keymap.h
	patch -p1 <pt
	$(guix build -q -f qmk.scm --no-substitutes)/bin/write_eeprom {{FULL}}
	git checkout write_eeprom/keymap.h
	patch -p1 <tmp
	git add write_eeprom/keymap.h
	rm pt tmp

# generate keymap files from org-mode
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


# flash firmware
flash: firmware
	#!/bin/sh
	set -euxo pipefail
	FIRMWARE=$(guix build -q -f guix.scm)/sarg_default.hex
	test -r $FIRMWARE

	dfu-programmer atmega32u4 flash --erase-first $FIRMWARE
	dfu-programmer atmega32u4 launch
