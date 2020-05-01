// -*- mode: scad; scad-preview-default-camera-parameters: (0 0 0 0 0 0 500) -*-
/*
     ___
    /___\
||    T    || deepening
||===---===|| mounting plate (1.5mm)    \ total 5mm
||==|___|==|| supporting plate (+3.5mm) /
||   ` `   || space for wiring 5 mm

*/

hole_size = 14;

deepening = 5;
wiring_space = 5;
thickness = 5;
wall_height = wiring_space+thickness+deepening;

mounting_plate_thickness = 1.5;
wall_thickness = 4;
sep = 5;

// controller board
ic_thickness = 1;
ic_size=[18,33];
ic_loc=[2.5*hole_size+3*sep+ic_size[0]/2, -hole_size*4+25, 0];

// thumb sector
tx = sep; ty = -167; l = 100; angle = 12;

cols=[[3, [-3*(hole_size + sep), 33]],
      [3, [-2*(hole_size + sep), 33]],
      [3, [-1*(hole_size + sep), 10]],
      [3, [0, 0]],
      [3, [hole_size + sep, 9]],
      [3, [2*(hole_size + sep), 10]]];

/* $vpr = [0,0,0]; $vpt = [0,0,0]; $vpd = 700; */

module hole() {
    square(size=hole_size, center=true);
}

module col(count, cx, cy) {
    for (a=[0:1:count-1])
        translate([cx,-cy-(hole_size+sep)*a])
            children();
}

module columns() {
    for (c = cols)
        col(c[0], c[1][0], c[1][1])
            children();
}

module thumbs() {
    for (a=[1:1:3])
        translate([tx+l*cos(90-a*angle), ty+l*sin(90-a*angle)])
            rotate(-a*angle)
            children();

    // slightly move leftmost key down
    translate([tx, ty+l-6])
        children();
}

module allkeys() {
    columns() children();
    thumbs() children();
}

module controller() {
    translate(ic_loc)
        square(size=ic_size, center=true);
}

module perimeter() {
    union() {
        offset(r=-10) offset(r=10) // round corners
            offset(delta=sep) allkeys()
            /* offset(r=-5) offset(r=5) */
            square(hole_size, center=true);

        controller();
    }
}

module clamp_space() {
    square(size=[4, hole_size + 2], center=true);
}

module wall() {
    linear_extrude(height=wall_height)
        difference() {
        offset(wall_thickness) perimeter();
        perimeter();
    }
}

module plate() {
    translate([0,0,wiring_space])
        difference() {
            linear_extrude(height=thickness)
                difference() {
                    perimeter();
                    allkeys() hole();
                }
            linear_extrude(height=thickness - mounting_plate_thickness)
                allkeys() clamp_space();
    }
}

module cherry_mx() {
    include <cherry_mx.scad>;
    translate([0,0,thickness]) keycap();
}

use <cap.scad>;

module 3dkeys() {
    translate([0,0,wiring_space+thickness])
        allkeys() cherry_mx();
}

module usb() {
    usb_w = 12; usb_h = 8;usb_l=15;
    translate([0,usb_l/2, 0])
        cube([usb_w, usb_l, usb_h], center=true);
}

module cutout() {
    union() {
        translate(ic_loc + [0, ic_size[1]/2+2.5, wiring_space+thickness+1])
            usb();

        // submerge controller in the plate
        translate([0,0,wiring_space+thickness-ic_thickness])
            linear_extrude(height=ic_thickness+1)
            controller();

        translate([0,0,wiring_space])
            linear_extrude(height=2)
            controller();

        translate([0,0,wiring_space-1]) {
            linear_extrude(height=thickness+1)
                difference() {
                    controller();

                    translate(ic_loc)
                        square(size=[ic_size[0]-6, ic_size[1]], center=true);
                }
        }

        usb_socket_height=2;
        translate(ic_loc + [0, ic_size[1]/2, wiring_space+thickness+usb_socket_height/2])
            cube([8,5,usb_socket_height], center=true);
    }
}


difference() {
    union() {
        wall();
        plate();
    }
    cutout();
}



if ($preview && false)
{
    /* color("white", 0.5) 3dkeys(); */

    /* color("black") */
    /*     translate(ic_loc + [0, ic_size[1]/2+2.5, wiring_space+thickness+1]) */
    /*         usb(); */

    color("blue") {
        translate([0,0,wiring_space+thickness-ic_thickness])
            linear_extrude(height=ic_thickness)
            controller();

        translate(ic_loc + [0, ic_size[1]/2, wiring_space+thickness+1])
            cube([8,5,2], center=true);
    }

}
