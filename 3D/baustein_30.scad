/* The following OpenSCAD design is a model of a Fischertechnik
   Baustein. It's purpose is to have a possibility to add
   electronics by adapting this design, but be able to integrate
   it in a model. The flexible nylon top characteristic can be
   created by inserting a metric screw and adding a thread in the
   hole.
   
   Copyright (c)2026 by Roland van Straten, All Rights Reserved. Commercial in Confidence.
   MIT License.
 */

// ============================================================
// Fischertechnik Baustein 30 — Parametric OpenSCAD
// ============================================================
//
// 4 T-slot grooves along X (full 30 mm length)
// + 1 groove on end face X = +L/2 (along Z, centered Y)
// + 1 hole on end face X = -L/2 (centered, Ø2 mm, 10 mm deep)
//
// Verified dims (forum.ftcommunity.de):
//   Bore Ø:      4.0 mm
//   Slit width:  3.0 mm
//   Bore center: 2.1 mm from surface
// ============================================================

// ==== PARAMETERS ====

block_length = 30;        // mm (X)
block_width  = 15;        // mm (Y)
block_height = 15;        // mm (Z)

groove_bore_d   = 4.0;    // mm
groove_slit_w   = 3.0;    // mm
groove_depth    = 2.1;    // mm — surface to bore center

end_hole_d      = 2.0;    // mm — hole diameter on left end
end_hole_depth  = 10.0;   // mm — hole shaft depth

tol = 0.1;                // printer tolerance
$fn = 64;

// ==== COMPUTED ====
gd  = groove_bore_d + tol;
gw  = groove_slit_w + tol;
gc  = groove_depth;
eps = 0.5;

// ============================================================
// Groove primitive: bore (cylinder along X) + slit (box)
// Bore center at origin, slit opens toward +Z
// ============================================================
module groove(len) {
    union() {
        rotate([0, 90, 0])
            cylinder(h = len, d = gd, center = true);
        translate([0, 0, gc/2])
            cube([len, gw, gc], center = true);
    }
}

// ============================================================
// Baustein 30
// ============================================================
module baustein_30() {
    L = block_length + eps;
    W = block_width;
    H = block_height;
    Heps = H + eps;

    difference() {
        cube([block_length, W, H], center = true);

        // ---- 4 longitudinal grooves (along X) ----

        // TOP: slit opens +Z
        translate([0, 0, H/2 - gc])
            groove(L);

        // BOTTOM: slit opens -Z
        translate([0, 0, -(H/2 - gc)])
            mirror([0, 0, 1])
                groove(L);

        // RIGHT (Y+): slit opens +Y
        translate([0, W/2 - gc, 0])
            rotate([-90, 0, 0])
                groove(L);

        // LEFT (Y-): slit opens -Y
        translate([0, -(W/2 - gc), 0])
            rotate([90, 0, 0])
                groove(L);

        // ---- 1 groove on end face (X = +L/2) ----
        // Runs along Z, centered on Y, slit opens +X
        translate([block_length/2 - gc, 0, 0])
            rotate([0, 90, 0])
                groove(Heps);

        // ---- 1 hole on opposite end face (X = -L/2) ----
        // Centered on face, Ø 2 mm, 10 mm deep into block
        translate([-block_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h = end_hole_depth, d = end_hole_d + tol);
    }
}

// ============================================================
baustein_30();

// DEBUG: cross-section at X = 0
// difference() {
//     baustein_30();
//     translate([0, -20, -20])
//         cube([40, 40, 40]);
// }
