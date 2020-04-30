// -*- mode: scad; scad-preview-default-camera-parameters: (0 0 0 0 0 0 500) -*-
btn_w = 14;
deepening = 5;
btn_expected_thickness = 1.5;
wall_thickness = 5;
thickness = 5;
total_height = 15;
sep = 5;
ic_size=[18,33];
ic_angle=0;
ic_loc=[(btn_w+sep)*3, -39-ic_size[0]/2];
/* ic_angle=75; */
/* ic_loc=[20, -14-4*(btn_w+sep)]; */
cols=[[3, [-2*(btn_w + sep), 33]],
      [3, [-1*(btn_w + sep), 10]],
      [3, [0, 0]],
      [3, [btn_w + sep, 9]],
      [3, [2*(btn_w + sep), 10]]];

$vpr = [0,0,0]; $vpt = [0,0,0];
$vpd = 700;

module hole() {
    square(size=btn_w, center=true);
}

module col(count, cx, cy) {
    for (a=[0:1:count-1])
        translate([cx,-cy-(btn_w+sep)*a]) children();
}

module columns() {
    for (c = cols) {
        col(c[0], c[1][0], c[1][1]) children();
    }
}

module thumbs() {
    tx = sep; ty = -167; l = 100; angle = 12;
    /* translate([tx,ty]) circle(10); */
    for (a=[0:1:3]) {
        translate([tx+l*cos(90-a*angle), ty+l*sin(90-a*angle)])
            rotate(-a*angle)
            children();
    }
}

module allkeys() {
    columns() children();
    thumbs() children();
}

module controller() {
    translate(ic_loc)
        rotate(ic_angle)
        square(size=ic_size, center=true);
}

module perimeter() {
    offset(sep)
    hull() {
        columns() hole();
        thumbs() hole();
        controller();
    }
}

module gap() {
    square(size=btn_w + 2, center=true);
}

/* difference() { */
/* perimeter(); */
/* keys(); */
/* } */

module wall() {
    linear_extrude(height=total_height)
        difference() {
        offset(wall_thickness) perimeter();
        perimeter();
    }
}

plate_top = total_height - thickness - deepening;
module plate() {
    translate([0,0,plate_top])
        difference() {
        linear_extrude(height=thickness)
            difference() {
            perimeter();
            allkeys() hole();
        }
        linear_extrude(height=thickness - btn_expected_thickness)
            allkeys() gap();

    }
}

module cherry_mx() {
    include <cherry_mx.scad>;
    translate([0,0,thickness]) keycap();
}

use <cap.scad>;

module 3dkeys() {
    translate([0,0,plate_top+thickness])
    {
        columns() cherry_mx();
        thumbs() cherry_mx();
    }
}


color("green") plate();
color("red") wall();

if ($preview) {
    3dkeys();

    color("blue")
        translate([0,0,plate_top-thickness])
        linear_extrude(height=3)
        controller();
}
