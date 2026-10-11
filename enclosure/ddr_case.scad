// ============================================================================
// DDR Mat Controller Enclosure
//
// Houses an Arduino Pro Micro + a short micro-USB -> USB-C (female) adapter
// dongle (so the fragile onboard micro-USB port never gets plugged directly -
// the dongle takes the abuse instead and is cheap/easy to replace), plus two
// panel-mount momentary buttons ("A" / "B") for menu navigation.
//
// Mounts by CLAMPING onto the edge of the wooden dance-mat deck
// (~half-inch / ~13-14mm thick): the box sits on top of the mat, a jaw
// integrated into the base reaches underneath, and an M4 bolt + captured nut
// cinches the mat between the box floor and the jaw. No glue, no holes in
// the mat.
//
// HOW TO USE
//   1. Everything you need to re-measure with calipers is called out below
//      under "MEASURE AND UPDATE THESE". Defaults are reasonable guesses,
//      not guaranteed to match your specific Pro Micro clone / adapter /
//      buttons.
//   2. Open in OpenSCAD (openscad.org, free), F5 to preview, F6 to render.
//   3. Export BASE and LID separately as STL (uncomment one `part=` line
//      at a time near the bottom, or just select/hide one half of the
//      preview and export - both are laid out side by side so you can also
//      export the whole F6 render as one STL and split in your slicer).
//   4. Print in PLA or PETG, 3 perimeters, >=20% infill. Enable supports
//      (or manually add a support blocker) under the lower clip jaw - it's
//      a cantilevered plate with nothing under it.
//   5. Pro Micro sits on 4 corner posts, held down with foam tape or a dab
//      of hot glue (most clones have no mounting holes). The adapter sits
//      in the floor pocket in front of the Pro Micro's USB port; secure it
//      with a little hot glue too so unplugging a USB-C cable doesn't pull
//      it loose.
// ============================================================================

$fn = 48;

/* ---------------------------------------------------------------------- */
/* MEASURE AND UPDATE THESE                                                */
/* ---------------------------------------------------------------------- */

// --- Pro Micro (ATmega32u4) board ---
pm_length     = 33.0;  // long axis
pm_width      = 17.8;  // short axis
pm_pcb_t      = 1.6;   // bare PCB thickness
pm_top_comp_h = 4.0;   // tallest part above the PCB top face (ICs/crystal)
pm_usb_w      = 8.0;   // micro-USB connector width on the board
pm_usb_h      = 3.2;   // micro-USB connector height above the PCB top face

// --- Micro-USB -> USB-C adapter dongle (amazon B07VBV1PY5) ---
// *** MEASURE THIS ONE WITH CALIPERS - these are placeholders only. ***
adapter_length = 22.0; // tip of the micro-USB plug to the face of the USB-C port
adapter_width  = 13.0; // width of the molded body / USB-C end
adapter_height = 7.0;  // thickness (top to bottom) of the molded body
usbc_port_w    = 10.2; // width of the USB-C female opening itself
usbc_port_h    = 4.0;  // height of the USB-C female opening itself

// --- A / B momentary buttons (12mm panel mount) ---
// *** Verify body_d / body_len against the specific button you buy - these
//     drive the box's internal height, and vary a lot between parts. ***
button_hole_d   = 12.2; // panel hole diameter (12mm button + 0.2 clearance)
button_body_d   = 12.5; // diameter of the switch body behind the panel
button_body_len = 15.0; // length of the switch body behind the panel
button_spacing  = 16.0; // center-to-center spacing between A and B
button_nut_flat = 15.5; // across-flats of the mounting nut (clearance recess under the lid, optional)

// --- Mat edge the case clips onto ---
// *** Measure the actual mat edge - "just over half inch" is ~13-14mm. ***
mat_thickness  = 14.0;
clip_clearance = 0.6;  // extra gap added to mat_thickness so it slides on
clip_depth     = 18.0; // how far the jaw reaches in under the mat
clip_jaw_t     = 4.5;  // thickness of the lower (moving/clamping) jaw
clip_back_t    = 3.5;  // thickness of the back wall joining the two jaws

/* ---------------------------------------------------------------------- */
/* Shell / fit parameters - fine to leave as-is                           */
/* ---------------------------------------------------------------------- */

wall_t  = 2.2;
floor_t = 2.2;
lid_t   = 2.2;
fillet_r = 1.5;

margin     = 3.0;  // clearance around parts inside the shell
rail_h     = 3.0;  // height of the Pro Micro support posts
rail_clear = 0.3;  // extra clearance either side of the Pro Micro width

post_d    = 4.0;   // Pro Micro support post diameter
post_inset = 4.0;  // inset of posts from the board's corners

bolt_d      = 4.5;               // M4 clearance hole
nut_flats   = 7.0;               // M4 nut across-flats
nut_pocket_h = 3.4;              // M4 nut thickness + a touch of slop

/* ---------------------------------------------------------------------- */
/* Derived layout - sections laid out along X in this order:              */
/*   [margin] [button bay] [Pro Micro] [adapter bay] [margin] [end wall]  */
/* ---------------------------------------------------------------------- */

button_bay_l = button_spacing + button_body_d + 4; // +2mm clearance each side

inner_l = margin*2 + button_bay_l + pm_length + adapter_length;
inner_w = pm_width + rail_clear*2 + margin*2;

inner_h = max(
  rail_h + pm_pcb_t + pm_top_comp_h + 3,   // clearance over the Pro Micro
  button_body_len + 3,                      // clearance for button bodies
  adapter_height + 4                        // clearance over the adapter
);

outer_l = inner_l + wall_t*2;
outer_w = inner_w + wall_t*2;
outer_h = inner_h + floor_t + lid_t;

// Section boundaries along X (global, interior coordinates)
sec_margin0_x0 = wall_t;
sec_margin0_x1 = sec_margin0_x0 + margin;

sec_btn_x0 = sec_margin0_x1;
sec_btn_x1 = sec_btn_x0 + button_bay_l;

sec_pm_x0 = sec_btn_x1;
sec_pm_x1 = sec_pm_x0 + pm_length;          // Pro Micro's USB port is at this end

sec_adp_x0 = sec_pm_x1;
sec_adp_x1 = sec_adp_x0 + adapter_length;

sec_margin1_x0 = sec_adp_x1;
sec_margin1_x1 = sec_margin1_x0 + margin;   // == outer_l - wall_t

pm_y0 = (outer_w - pm_width) / 2;           // Pro Micro centered across the width

usb_center_z = floor_t + rail_h + pm_pcb_t + pm_usb_h/2;

btn1_x = sec_btn_x0 + 2 + button_body_d/2;
btn2_x = btn1_x + button_spacing;
btn_y  = outer_w / 2;

/* ---------------------------------------------------------------------- */
/* Helpers                                                                 */
/* ---------------------------------------------------------------------- */

module rounded_rect(l, w, h, r) {
  linear_extrude(height = h)
    hull() {
      for (x = [r, l - r], y = [r, w - r])
        translate([x, y]) circle(r = r);
    }
}

module hex_nut_pocket(flats, depth) {
  cylinder(r = (flats/2) / cos(30), h = depth, $fn = 6);
}

/* ---------------------------------------------------------------------- */
/* Base shell                                                              */
/* ---------------------------------------------------------------------- */

module base_shell() {
  difference() {
    union() {
      // outer shell
      rounded_rect(outer_l, outer_w, floor_t + inner_h, fillet_r);

      // mat clip - lower jaw + back wall, hanging under the box footprint.
      // Open mouth at y=0 (mat slides in from the front edge of the box);
      // closed end (back wall) at y=clip_depth.
      gap = mat_thickness + clip_clearance;
      translate([0, 0, -(gap + clip_jaw_t)])
        cube([outer_l, clip_depth, clip_jaw_t]);
      translate([0, clip_depth - clip_back_t, -(gap + clip_jaw_t)])
        cube([outer_l, clip_back_t, gap + clip_jaw_t + floor_t]);
    }

    // hollow interior
    translate([wall_t, wall_t, floor_t])
      cube([inner_l, inner_w, inner_h + 1]);

    // USB-C adapter port cutout through the far end wall
    translate([outer_l - wall_t - 1, outer_w/2 - usbc_port_w/2, usb_center_z - usbc_port_h/2])
      cube([wall_t + 2, usbc_port_w, usbc_port_h]);

    // wire entry for the 4 direction-pad leads, through the near end wall,
    // low and to one side so it clears the button bay above it
    translate([-1, wall_t + 5, floor_t + 4])
      rotate([0, 90, 0])
      cylinder(d = 7, h = wall_t + 2);

    // M4 clamp bolt: through-hole up through the lower jaw and into the gap
    gap2 = mat_thickness + clip_clearance;
    bolt_x = outer_l / 2;
    bolt_y = clip_depth * 0.55;
    translate([bolt_x, bolt_y, -(gap2 + clip_jaw_t) - 1])
      cylinder(d = bolt_d, h = clip_jaw_t + gap2 + 2);
    // captured hex nut pocket in the underside of the lower jaw
    translate([bolt_x, bolt_y, -(gap2 + clip_jaw_t) - 0.1])
      hex_nut_pocket(nut_flats, nut_pocket_h);

    // lid screw pilot holes (blind - screws self-tap into these from above)
    for (p = lid_screw_positions())
      translate([p[0], p[1], floor_t + inner_h - 6])
        cylinder(d = 2.0, h = 6.1);
  }

  // Pro Micro support posts (0.1mm sunk into the floor so the union is a
  // true solid merge, not just a coincident-face touch)
  for (dx = [post_inset, pm_length - post_inset])
    for (dy = [post_inset, pm_width - post_inset])
      translate([sec_pm_x0 + dx, pm_y0 + dy, floor_t - 0.1])
        cylinder(d = post_d, h = rail_h + 0.1);

  // adapter retention pocket floor ribs (friction grip on the long edges)
  translate([sec_adp_x0, outer_w/2 - adapter_width/2 - 1.5, floor_t - 0.1])
    cube([sec_adp_x1 - sec_adp_x0, 1.5, 3.1]);
  translate([sec_adp_x0, outer_w/2 + adapter_width/2, floor_t - 0.1])
    cube([sec_adp_x1 - sec_adp_x0, 1.5, 3.1]);

  // lid screw bosses
  for (p = lid_screw_positions())
    translate([p[0], p[1], floor_t - 0.1])
      cylinder(d = 6, h = inner_h - 6 + 0.1);
}

function lid_screw_positions() = [
  [wall_t + 4, wall_t + 4],
  [outer_l - wall_t - 4, wall_t + 4],
  [wall_t + 4, outer_w - wall_t - 4],
  [outer_l - wall_t - 4, outer_w - wall_t - 4]
];

/* ---------------------------------------------------------------------- */
/* Lid                                                                     */
/* ---------------------------------------------------------------------- */

module lid() {
  difference() {
    rounded_rect(outer_l, outer_w, lid_t, fillet_r);

    // A / B button holes
    translate([btn1_x, btn_y, -1]) cylinder(d = button_hole_d, h = lid_t + 2);
    translate([btn2_x, btn_y, -1]) cylinder(d = button_hole_d, h = lid_t + 2);

    // screw clearance holes down to the base's bosses
    for (p = lid_screw_positions())
      translate([p[0], p[1], -1])
        cylinder(d = 2.8, h = lid_t + 2);
  }
}

/* ---------------------------------------------------------------------- */
/* Layout for printing                                                     */
/* Set `part` to "base", "lid", or "both" (e.g. -D part=\"base\" on the   */
/* command line, or just edit the line below) to control STL export.      */
/* ---------------------------------------------------------------------- */

part = "both";

if (part == "base" || part == "both") base_shell();
if (part == "lid" || part == "both")
  translate([0, part == "both" ? outer_w + 10 : 0, 0]) lid();
