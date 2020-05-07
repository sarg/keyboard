module keycap() {
    translate([0,0,0.5]) {
        hull() {
            cube(size=[18,18,1], center=true);
            translate([0,0,7])
                cube(size=[12,12,1], center=true);
        }
    }
}

keycap();
