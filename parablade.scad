include <BOSL2/std.scad>

EPS = 0.001;

TOLERANCE = 0.5;

BLADE_THICKNESS = 4;
BLADE_WIDTH = 16;
BLADE_LENGTH = 50;
BLADE_EDGE_INSET = 5;
BLADE_POINT_ANGLE = 35;

BLADE_CUTAWAY_LENGTH = 20;
BLADE_CUTAWAY_WIDTH = 2;

SHEATH_THICKNESS = 1;
SHEATH_LENGTH = 55;

SHEATH_WINDOW = 10;

module Blade(
  bladeThickness = BLADE_THICKNESS,
  bladeWidth = BLADE_WIDTH,
  bladeLength = BLADE_LENGTH,
  bladeEdgeInset = BLADE_EDGE_INSET,
  bladePointAngle = BLADE_POINT_ANGLE,
  angledEnd = true
) {
  bladePointInset = bladeEdgeInset / cos(bladePointAngle);

  down(bladeThickness / 2)
    intersection() {
      // Straight Blade
      union() {
        // Blank
        cube([bladeWidth - bladeEdgeInset + EPS, bladeLength, bladeThickness]);
        // Edge
        move(
          [
            bladeWidth - bladeEdgeInset,
            bladeLength / 2,
            bladeThickness / 2,
          ]
        )
          yrot(90)
            prismoid(
              size1=[bladeThickness, bladeLength],
              size2=[0, bladeLength],
              h=bladeEdgeInset
            );
      }
      ;
      // Angled Point
      if (angledEnd) {
        union() {
          move(
            [
              0,
              bladeLength - bladePointInset,
              bladeThickness / 2,
            ]
          )
            rot([-90, 90, -bladePointAngle]) {
              // Edge
              prismoid(
                size1=[bladeThickness, 2 * bladeLength],
                size2=[0, 2 * bladeLength],
                h=bladeEdgeInset
              );
              move([0, 0, EPS])
                cube([bladeThickness, 2 * bladeLength, 2 * bladeLength], anchor=TOP);
            }
        }
      } else {
        cube(bladeLength, anchor=FRONT + LEFT);
      }
    }
  ;
}

difference() {
  Blade();
  // Cutaway
  move([BLADE_CUTAWAY_WIDTH, BLADE_CUTAWAY_LENGTH, 0])
    cube(BLADE_LENGTH, anchor=BACK + RIGHT);
}

// Sheath
module Sheath(
  thickness,
  length
) {
  halfEdgeAngle = atan(BLADE_THICKNESS / 2 / BLADE_EDGE_INSET);
  sheathBladeInsetDelta = thickness * tan(halfEdgeAngle / 2);
  sheathBladeInsetExtra = thickness / sin(halfEdgeAngle);

  left(thickness)
    Blade(
      bladeThickness=BLADE_THICKNESS + thickness * 2,
      bladeWidth=BLADE_WIDTH + thickness + sheathBladeInsetExtra,
      bladeLength=length,
      bladeEdgeInset=BLADE_EDGE_INSET + sheathBladeInsetExtra - sheathBladeInsetDelta,
      angledEnd=false
    );
}

difference() {
  back(TOLERANCE)
    Sheath(SHEATH_THICKNESS + TOLERANCE, SHEATH_LENGTH + SHEATH_THICKNESS);
  Sheath(TOLERANCE, SHEATH_LENGTH + TOLERANCE);
  // End Window
  back(TOLERANCE + SHEATH_LENGTH)
    cube([BLADE_WIDTH * 1.2, SHEATH_WINDOW, BLADE_THICKNESS], anchor=BACK + LEFT + BOTTOM);
  // Mid Window
  back(TOLERANCE + (SHEATH_LENGTH / 2))
    cube([BLADE_WIDTH * 1.2, SHEATH_WINDOW, BLADE_THICKNESS], anchor=LEFT + BOTTOM);
}
