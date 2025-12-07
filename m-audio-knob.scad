/*
MEASUREMENTS

- Knob Height = 18.6mm
- Outer Diameter = 17.0mm
- Top Inset Diameter = 12.6mm
- Outer Ridge Height = 9mm
- Outer Ridge Depth = 0.2mm
- Indicator Width = 1.4mm
- Inner Cup Depth = 4.5mm
- Inner Cup Diameter = 5.9mm
    -> Peg Diameter = 5.8mm
- Diameter of Peg at cutout = 4.25mm

I didn't measure the chamfer depth lol
*/

$fs = 0.7;
$fa = 1;

KNOB_HEIGHT = 18.6;
OUTER_DIAMETER_TOP = 17.0;

TAPER_START_HEIGHT = 3;
OUTER_DIAMETER_BOTTOM = 18.0;

TOP_INSET_DIAMETER = 12.6;
TOP_INSET_DEPTH = 0.3;

OUTER_RIDGE_HEIGHT = 9;
OUTER_RIDGE_DEPTH = 0.5;
OUTER_RIDGE_WIDTH = 2.5;
OUTER_RIDGE_CHAMFER = 0.5;
OUTER_RIDGE_COUNT = 11;

INDICATOR_WIDTH = 1.6;
INDICATOR_HEIGHT = 0.4;

INNER_CUP_DEPTH = 4.6;
INNER_CUP_DIAMETER = 6.0;
DIAMETER_OF_PEG_AT_CUTOUT = 4.3;


PEGHOLE_DEPTH = 15.3;

WALL_THICKNESS = 1;

BENT_PEG_ROTATION = [
  -1.3967,
  8.14943,
  -0.198028,
];

include <BOSL2/std.scad>;

ridgeInsetAngle = atan(OUTER_RIDGE_DEPTH / OUTER_RIDGE_HEIGHT);
ridgeAngleStep = 360 / OUTER_RIDGE_COUNT;

difference() {
  union() {
    difference() {
      // Outer Body
      cyl(d=OUTER_DIAMETER_TOP, h=KNOB_HEIGHT, chamfer2=1, anchor=BOTTOM);
      // Top Inset
      up(KNOB_HEIGHT - TOP_INSET_DEPTH)
        cylinder(d=TOP_INSET_DIAMETER, h=KNOB_HEIGHT, anchor=BOTTOM);
      // Outer Ridges
      for (i = [0:1:OUTER_RIDGE_COUNT]) {
        rotate([0, 0, ridgeAngleStep * i])
          fwd(OUTER_DIAMETER_TOP / 2 - OUTER_RIDGE_DEPTH)
            // up(KNOB_HEIGHT - OUTER_RIDGE_HEIGHT)
            //   xrot(-ridgeInsetAngle)
                cuboid(
                  size=[
                    OUTER_RIDGE_WIDTH,
                    4 * OUTER_RIDGE_WIDTH,
                    KNOB_HEIGHT,
                  ], anchor=BOTTOM + BACK,
                  chamfer=OUTER_RIDGE_CHAMFER,
                  edges="Z"
                );
      }
    }

    // Taper
    cyl(d1=OUTER_DIAMETER_BOTTOM, d2=OUTER_DIAMETER_TOP - OUTER_RIDGE_DEPTH * 2, h=KNOB_HEIGHT - TAPER_START_HEIGHT, anchor=BOTTOM);

    // Indicator
    cylinder(d=INDICATOR_WIDTH, h=KNOB_HEIGHT - TOP_INSET_DEPTH + INDICATOR_HEIGHT);
    cuboid(
      size=[
        INDICATOR_WIDTH,
        OUTER_DIAMETER_TOP / 2 + INDICATOR_HEIGHT,
        KNOB_HEIGHT - TOP_INSET_DEPTH + INDICATOR_HEIGHT,
      ], anchor=BOTTOM + BACK,
      chamfer=INDICATOR_HEIGHT,
      edges=TOP + FWD
    );
  }
  // Inner Cup
  down(1)
    cyl(d=(OUTER_DIAMETER_TOP - WALL_THICKNESS * 2), h=(INNER_CUP_DEPTH + 1), anchor=BOTTOM);

  // Peg Hole
  rotate(BENT_PEG_ROTATION)
    difference() {
      cylinder(d=INNER_CUP_DIAMETER, h=PEGHOLE_DEPTH, anchor=BOTTOM);
      back(DIAMETER_OF_PEG_AT_CUTOUT - INNER_CUP_DIAMETER / 2)
        cube(2 * KNOB_HEIGHT, anchor=BOTTOM + FRONT);
    }
}
