// ============================================================
// Fischertechnik Baustein 15 — PCB Housing
// ============================================================
//
// 15×15×15 mm, hollow (1 mm walls), open at Y+ for PCB.
// 3 mm hole centered on back face (Y-).
// 4 triangular supports in inner corners for PCB.
// Split T-tongue on bottom for Baustein 30 connection.
//
// ---- PCB DIMENSIONS ----
//   Recommended PCB:   12.5 × 12.5 mm
//   PCB seats at:      5 mm from back wall
// ============================================================

// ==== PARAMETERS ====

block_length = 15;
block_width  = 15;
block_height = 15;

wall = 1.0;

groove_bore_d   = 4.0;
groove_slit_w   = 3.0;
groove_depth    = 2.1;

tongue_clearance = 0.15;
split_width = 0.5;

back_hole_d = 3.0;

support_h   = 5.0;
support_leg = 3.0;

$fn = 64;

// ==== COMPUTED ====
td = groove_bore_d - 2 * tongue_clearance;
tw = groove_slit_w - 2 * tongue_clearance;
tc = groove_depth;

cavity_x = block_length - 2 * wall;
cavity_z = block_height - 2 * wall;
cavity_y = block_width - wall;

split_depth = tc + td/2 + 0.1;

back_wall_y = -block_width/2 + wall;

cx = cavity_x / 2;
cz = cavity_z / 2;

// ============================================================
module tongue_2d() {
    union() {
        translate([0, tc])
            circle(d = td);
        translate([-tw/2, 0])
            square([tw, tc]);
    }
}

// ============================================================
// Base triangle at bottom-left corner (-X, -Z).
//
// Looking at the back wall (XZ plane):
//
//        -X wall
//         |
//         |\ 
//         | \    ← hypotenuse faces center
//         |__\
//        -Z wall
//
// Legs flush against -X and -Z walls,
// point (hypotenuse) faces toward center.
// ============================================================
module base_corner_support() {
    translate([-cx, back_wall_y, -cz])
        rotate([-90, 90, 0])
            linear_extrude(height = support_h)
                polygon(points = [
                    [0, 0],
                    [-support_leg, 0],
                    [0, -support_leg]
                ]);
}

// ============================================================
module baustein_15_pcb() {
    L = block_length;
    W = block_width;
    H = block_height;

    union() {
        difference() {
            cube([L, W, H], center = true);

            // ---- PCB cavity ----
            translate([0, wall/2, 0])
                cube([cavity_x, cavity_y + 0.1, cavity_z],
                     center = true);

            // ---- 3 mm hole on back face (Y-) ----
            translate([0, -W/2 - 0.05, 0])
                rotate([-90, 0, 0])
                    cylinder(h = wall + 0.1, d = back_hole_d);
        }

        // ---- 4 triangular corner supports ----
        base_corner_support();

        mirror([1, 0, 0])
            base_corner_support();

        mirror([0, 0, 1])
            base_corner_support();

        mirror([1, 0, 0])
            mirror([0, 0, 1])
                base_corner_support();

        // ---- Tongue on bottom ----
        difference() {
            translate([0, 0, -H/2])
                rotate([90, 180, 90])
                translate([0, 0, -L/2])
                    linear_extrude(height = L)
                        tongue_2d();

            translate([0, 0, -H/2 - split_depth/2])
                cube([L + 0.1, split_width, split_depth],
                     center = true);
        }
    }
}

// ============================================================
baustein_15_pcb();
