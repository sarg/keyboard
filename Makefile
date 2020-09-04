all:
	lein run
	openscad -o left.stl _left.scad
	openscad -o right.stl _right.scad

.PHONY: all
