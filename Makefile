all:
	lein run
	openscad -o left.stl _left.scad
	openscad -o right.stl _right.scad

qmk_firmware/keyboards/sarg:
	cd qmk_firmware/keyboards && ln -s ../../firmware sarg

firmware: qmk_firmware/keyboards/sarg
	qmk compile -kb sarg -km default

flash:
	qmk flash -kb sarg -km default

.PHONY: all firmware
