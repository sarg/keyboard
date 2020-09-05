all:
	lein run
	openscad -o left.stl _left.scad
	openscad -o right.stl _right.scad

qmk_firmware/keyboards/sarg:
	cd qmk_firmware/keyboards && ln -s ../../firmware sarg

firmware: qmk_firmware/keyboards/sarg
	cd qmk_firmware && bin/qmk compile -kb sarg -km default

.PHONY: all firmware
