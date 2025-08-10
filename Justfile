default:
	@just --list

all:
	lein run
	openscad -o left.stl _left.scad
	openscad -o right.stl _right.scad

firmware:
	guix build -f guix.scm

svg:
	keymap parse -q firmware/keymaps/default/keymap.json > k.yaml
	keymap draw k.yaml > layout.svg
	rm k.yaml

flash: firmware
	#!/bin/sh
	set -euxo pipefail
	FIRMWARE=$(guix build -f guix.scm)/sarg_default.hex
	test -r $FIRMWARE

	dfu-programmer atmega32u4 flash --erase-first $FIRMWARE
	dfu-programmer atmega32u4 launch
