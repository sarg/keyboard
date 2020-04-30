module keycap() {
    hull()
    {
        linear_extrude(height=1)
            difference() {
            square(size=18, center=true);
            square(size=16, center=true);
        }
        translate([0,0,7])
            linear_extrude(height=1)
            square(size=12, center=true);
    }
}

keycap();
