// -*- mode: scad; scad-preview-default-camera-parameters: (0 0 0 0 0 0 500) -*-
btn_w = 14;
thickness = 4;
total_height = 18;
sep = 5;
ic=[33,18];
cols=[[3, [-2*(btn_w + sep), 33]],
      [3, [-1*(btn_w + sep), 10]],
      [4, [0, 0]],
      [3, [btn_w + sep, 9]],
      [3, [2*(btn_w + sep), 10]]];

$vpd = 700;

module btn() { color("green") square(size=btn_w, center=true); }
module row(count, cx, cy) {
    for (a=[0:1:count-1])
        translate([cx,-cy-(btn_w+sep)*a]) btn();
}

// rows
module keys() {
    for (c = cols) {
        row(c[0], c[1][0], c[1][1]);
    }

// thumb cluster
    tx = sep; ty = -165; l = 100;
    for (a=[1:1:3]) {
        translate([tx+l*cos(90-a*10), ty+l*sin(90-a*10)])
            rotate(-a*10)
            btn();
    }
}

module controller() {
    translate([(btn_w+sep)*3, -ic[0]/2])
        color("blue")
        rotate([0,0,90])
        square(size=ic, center=true);
}

module perimeter() {
    hull() { keys(); controller(); }
}

linear_extrude(height=total_height)
difference() {
    offset(8) perimeter();
    offset(5) perimeter();
}

color("green")
translate([0,0,total_height - thickness - 3])
linear_extrude(height=thickness)
difference() {
    offset(8) perimeter();
    keys();
}
