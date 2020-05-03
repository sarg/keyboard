// -*- mode: scad; scad-preview-default-camera-parameters: (0 0 0 0 0 0 500) -*-
/*
     ___
    /___\
||    T    || deepening
||===---===|| mounting plate (1.5mm)    \ total 5mm
||==|___|==|| supporting plate (+3.5mm) /
||   ` `   || space for wiring 5 mm

*/

$fn = 50;
hole_size = 14;
deepening = 5;
wiring_space = 5;
thickness = 4;
include <controller.scad>;
wall_height = wiring_space+thickness+deepening;
mounting_plate_thickness = 1.5;
wall_thickness = 2;
sep = 5;
ic_loc=[2.5*hole_size+3*sep+ic_size[0]/2+wall_thickness, -hole_size*4+35, 0];

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

module perimeter() {
    union() {
        offset(r=-5) offset(r=5) // round corners
            offset(delta=sep) allkeys()
            /* offset(r=-5) offset(r=5) */
            square(hole_size, center=true);

    }
}

module clamp_space() {
    square(size=[4, hole_size + 2], center=true);
}

module wall() {
    linear_extrude(height=wall_height)
    union() {
        difference() {
            offset(wall_thickness) children();
            children();
        }
    }
}


module plate() {
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
    translate([0,0,thickness])
        allkeys() cherry_mx();
}

module perimeter_with_controller() {
    union() {
        translate(ic_loc) controller_perimeter();
        perimeter();
    }
}

module bottom() {
    color("#303030") {
        wall() perimeter_with_controller();
    }

    // bottom plate
    translate([0,0,-1])
        linear_extrude(height=1)
        offset(wall_thickness)
        perimeter_with_controller();

    burt_thickness = wiring_space;
    color("red")
        translate([0,0,wiring_space-burt_thickness])
        linear_extrude(height=burt_thickness)
        difference() {
            perimeter_with_controller();
            offset(-1.5) perimeter_with_controller();
        }
}




module ear() {
    translate([0,0,-1])
    difference() {
        linear_extrude(height=10)
            offset(2) offset(-2)
        hull() {
            circle(d=12);
            square(6);
        }
        cylinder(h=10,d=6);
    }
}

module ears() {
    // left top
    translate([-4*(hole_size+sep),-30]) ear();
    translate([-4*(hole_size+sep),-30]) rotate(-90) ear();

    // left bottom
    translate([-4*(hole_size+sep),-74]) ear();
    translate([-4*(hole_size+sep),-74]) rotate(-90) ear();

    // top right
    translate([(hole_size+sep),10]) rotate(180) ear();

    // bottom right
    translate(ic_loc+[-4,-39]) rotate(90) ear();
}

module usb_cutout() {
    translate([0, ic_size[1]/2, thickness]) usb();
    translate([0, ic_size[1]/2, thickness+usb_socket_height/2])
        cube([8,5,usb_socket_height], center=true);
}

module trrs_cutout() {
    translate(trrs_pos) {
        translate([ic_size[0]/2+wall_thickness,0,0]) {
            rotate([0,90,0]) cylinder(h=4.5,d=6);

        }
    }
}

module bottom_with_cutouts() {
    difference() {
        bottom();
        translate(ic_loc+[0,0,wiring_space])
            union() { usb_cutout(); trrs_cutout(); }
    }
}

module plate_part() {
    difference() {
        union() {
            plate();
            translate(ic_loc) controller();
        }

        // to ensure that the plate could be inserted into the case
        // trim 0.2 mm from it
        linear_extrude(height=thickness)
            difference() {
                perimeter_with_controller();
                offset(-0.2) perimeter_with_controller();
            }
    }
}

ears();
bottom_with_cutouts();
translate([0,0,wiring_space] + [200,0,0]) {
    plate_part();

    /* if ($preview) */
        color("white", 0.5) 3dkeys();
}

/* if ($preview) */
{
    color("red") translate(ic_loc + [0,0,wiring_space]) trrs_socket();

    /* color("black") */
    /*     translate(ic_loc + [0, ic_size[1]/2+2.5, wiring_space+thickness+1]) */
    /*         usb(); */


}
