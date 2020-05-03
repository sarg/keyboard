ic_thickness = 1;
ic_size=[18,33];

usb_socket_height=2;
trrs_d=8;
trrs_w=10;

trrs_pos=[0, -ic_size[1]/2-trrs_d/2-trrs_w/2,(thickness+deepening)/2-0.5];
module usb() {
    usb_w = 12; usb_h = 8;usb_l=15;
    translate([0,usb_l/2, 0])
        cube([usb_w, usb_l, usb_h], center=true);
}

module board() {
    square(size=ic_size, center=true);
}

module trrs_socket() {
    translate(trrs_pos) {
        translate([ic_size[0]/2+wall_thickness,0,0]) {
            rotate([0,90,0]) cylinder(h=4.5,d=6, $fn=50);

            translate([wall_thickness,0,0])
                rotate([0,90,0]) cylinder(h=2,d=8, $fn=50);

            translate([-11.8,0,0]) rotate([0,90,0])
                cylinder(h=11.8,d=8, $fn=50);

            translate([-11.8-3,0])
                cube([3,2,1]);
        }
    }
}

module controller_perimeter() {
    union() {
        offset(delta=2) board();
        offset(delta=2)
        translate(trrs_pos)
            square([ic_size[0], trrs_w], center=true);
    }
}

module cutout() {
    union() {
        // submerge controller in the plate
        translate([0,0,thickness-ic_thickness])
            linear_extrude(height=ic_thickness+1)
            board();

        // space for IC pins
        linear_extrude(height=thickness)
            difference() {
                board();
                square(size=ic_size-[2.6*2, 0], center=true);
            }
    }
}

module promicro() {
    translate([0,0,-ic_thickness])
        linear_extrude(height=ic_thickness)
        board();

    translate([-4, ic_size[1]/2-4])
        cube([8,5,usb_socket_height]);
}


module controller() {
    difference() {
        linear_extrude(height=thickness)
            offset(delta=2) board();

        cutout();
    }

    if ($preview) {
        color("blue")
            translate([0,0,thickness]) promicro();

    }
}


