/*
Original: https://www.thingiverse.com/thing:4241105 (user dukyduke on Thingiverse)
License: CC-BY-SA

Changes by Aptimex:
- Add a separate retaining bar to keep the tissue box inside when the outer box is lifted 
- Change pattern parameters to be more intuitive in relation to what you see in the output
- Translate comments to English
*/

// Print thickness
thickness = 2.4;

/* [Cardboard tissue box size] */
width=230;
depth=125;
high=92;

// Tissue opening width
opening_width = 155;
// Tissue opening depth
opening_depth = 10;

/* [Pattern] */

// Patter depth
deep = 1;

// Pattern diameter; edge-to-edge on each outer hexagon
diameter = 30;

// Pattern Spacing; edge-to-edge distance between hexagon sides
spacing = 11;

/* [Retainer dimensions] */
ret_height = 20;
ret_width = 20;
ret_thickness = 1.2;
//Diameter of the cylinders on the box that the bar "locks" onto
ret_diameter = 6;


/* Parameters after here are derived and/or not meant to be customized */

// Convert hex edge-to-edge dia to corner-to-corner dia (and then radius), as used by the original code
corner_dia = 2/sqrt(3) * diameter;
radius = corner_dia / 2;
// Distance between hexagon corners (along the same column)
space = diameter/2 * sqrt(3) + spacing;

ret_outer_dia = ret_diameter + 2;
e = .001 + 0;
$fn=100 + 0;

module box() {
    translate([0, 0, (high+thickness)/2])
    difference() {
        volume();
        
        // Space for the tissue box
        translate([0, 0, -thickness]) cube(size=[width,depth,high+thickness], center=true);
        
        // Tissue slot opening
        translate([-(opening_width/2), 0, (high/2)-2]) cylinder(thickness+deep+2,d=opening_depth);
        translate([(opening_width/2), 0, (high/2)-2]) cylinder(thickness+2,d=opening_depth);
        translate([0, 0, (high/2)]) cube(size=[opening_width,opening_depth,thickness+deep+2], center=true);
        
        // 4 corners
        translate([(width/2+thickness+deep), (depth/2+thickness+deep), 0]) rotate([0, 0, 45]) cube([2*(thickness+deep), 2*(thickness+deep), high+thickness+deep], center=true);
        translate([-(width/2+thickness+deep), (depth/2+thickness+deep), 0]) rotate([0, 0, 45]) cube([2*(thickness+deep), 2*(thickness+deep), high+thickness+deep], center=true);
        translate([(width/2+thickness+deep), -(depth/2+thickness+deep), 0]) rotate([0, 0, 45]) cube([2*(thickness+deep), 2*(thickness+deep), high+thickness+deep], center=true);
        translate([-(width/2+thickness+deep), -(depth/2+thickness+deep), 0]) rotate([0, 0, 45]) cube([2*(thickness+deep), 2*(thickness+deep), high+thickness+deep], center=true);
    }
    
    nub();
    mirror([0, 1, 0]) nub();
}

// Protruding cylinder that the retainer locks onto
module nub() {
    color([1, 0, 0]) translate([0, (depth-ret_thickness)/2, ret_height/2])  rotate([90, 0, 0]) cylinder(d=ret_diameter, h=ret_thickness, center=true);
}

// plain box volume
module volume() {
    union() {
        // the big basic cube
        cube(size=[width+2*thickness, depth+2*thickness, high+thickness], center=true);
    
        // pattern on each side
        big_side();
        mirror([0,1,0]) big_side();
        small_side();
        mirror([1,0,0]) small_side();
    }
}

// apply the patterns on a large side
module big_side() {
    intersection() {
        union() {
            for(z = [-(high/2): space*(5/3) : (high/2)+space] )
            for(x = [-(width/2)-space : space : (width/2)+space]) {
                // Line 1
                hex_element(pos = [x, -(depth/2+thickness), z], rot = [90, 90, 0], r= radius );
                // Line 2
                hex_element(pos = [x+space/2, -(depth/2+thickness), z+space/2+space/3], rot = [90, 90, 0], r= radius );
            }
        }
        translate([0, -(depth/2+thickness), 0]) cube([width+thickness*2, deep, high+thickness], center=true);
    }
}

// apply the patterns on a small side
module small_side() {
    intersection() {
        union() {
            for(z = [-(high/2): space*(5/3) : (high/2)+space] )
            for(y = [-(depth/2)-space+1.25 : space : (depth/2)+space]) {
                // line 1
                hex_element(pos = [width/2+thickness, y, z], rot = [0, 90, 0], r= radius );
                // line 2
                hex_element(pos = [width/2+thickness, y+space/2, z+space/2+space/3], rot = [0, 90, 0], r= radius );
            }
        }
        translate([width/2+thickness, 0, 0]) cube([deep, depth+2*thickness, high+thickness], center=true);
    }
}

// basic hex pattern
module hex_element(pos = [undef, undef, undef], rot = [undef, undef, undef], r) {
    union() {
        difference() {
            translate(pos) rotate(rot) cylinder(deep, r1=r, r2=(3/4)*r, center=true, $fn=6);
            translate(pos) rotate(-rot) cylinder(deep+0.01, r1=(2/4)*r, r2=(1/4)*r, center=true, $fn=6);
        }
        translate(pos) rotate(rot) cylinder(deep, r1=(1/3)*r, r2=(1/6)*r, center=true, $fn=6);
    }
}

// Optional removeable retainer that prevents the tissue box from coming out when the outer box is lifted
module retainer_half() {
    //cross-bar
    translate([0, 0, ret_thickness/2]) cube(size=[ret_width, depth-2*e, ret_thickness], center=true);
    
    //latch
    translate([0, (depth-ret_thickness)/2-e, ret_height/2]) {
        difference() {
            cube(size=[ret_width, ret_thickness, ret_height], center=true);
            color([0, 1, 0]) rotate([90, 0, 0]) cylinder(d=ret_outer_dia, h=ret_thickness+e, center=true);
            color([0, 0, 1]) translate([-ret_outer_dia/2, 0, -ret_outer_dia/4]) cube(size=[(ret_width+ret_outer_dia)/2, ret_thickness+e, ret_outer_dia], center=true);
            
        }
        
        //color([1, 0, 0]) rotate([90, 0, 0]) cylinder(d=ret_diameter, h=ret_thickness, center=true);
    }
    
    
}

// Creates the retainer from two halves
module retainer() {
    retainer_half();
    mirror([0, 1, 0]) retainer_half();
    
}

/*
// This cross-section makes it easier to develop/debug the retainer. 
intersection() {
    color([1, 0, 0]) {
        translate([0, 0, 10/2])
        cube(size=[width+2*thickness, depth+2*thickness, 10], center=true);
    }
    box();
}
*/

box();
retainer();
