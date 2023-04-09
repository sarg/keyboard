all:
	lein run
	openscad -o left.stl _left.scad
	openscad -o right.stl _right.scad

qmk_firmware/keyboards/sarg:
	cd qmk_firmware/keyboards && ln -s ../../firmware sarg

firmware: qmk_firmware/keyboards/sarg
	guix shell avr-toolchain make -- make -C qmk_firmware sarg:default

flash:
	guix shell avr-toolchain make -- make -C qmk_firmware sarg:default:avrdude

.PHONY: all firmware
