include <BOSL2/std.scad>

$fs = 0.5;
$fa = 1;

EPS = 0.001;

TOLERANCE = 0.3;

BLADE_THICKNESS = 4;
BLADE_WIDTH = 16;
BLADE_LENGTH = 50;
BLADE_EDGE_INSET = 5;
BLADE_POINT_ANGLE = 35;

BLADE_CUTAWAY_LENGTH = 25;
BLADE_CUTAWAY_WIDTH = 2;

// Hilt

HILT_LENGTH = 2;
HILT_WIDTH = 19;
HILT_HEIGHT = 7;

HANDLE_RADIUS = 1;
HANDLE_LENGTH = 20;

// Handguard

// this is the z aligned component.
HANDGUARD_THICKNESS = 4;

// Radial aligned component
HANDGUARD_WIDTH = 2;
HANDGUARD_RX = 6;
HANDGUARD_RY = 10;
HANDGUARD_POMMEL_X = 4;

HANDLE_X_OFFSET = -2;

// Sheath

SHEATH_THICKNESS = 1;
// SHEATH_LENGTH = 55;
SHEATH_LENGTH = BLADE_LENGTH;

SHEATH_WINDOW = 10;

TOP_WINDOW_POSITION = 4;
BOT_WINDOW_POSITION = SHEATH_LENGTH;
MID_WINDOW_POSITION = (TOP_WINDOW_POSITION + BOT_WINDOW_POSITION) / 2;

// Spring/catch
SPRING_WIDTH = BLADE_CUTAWAY_WIDTH - 2 * TOLERANCE;
CATCH_HEIGHT = 1.5;
CATCH_LENGTH = 2;
assert(CATCH_HEIGHT > TOLERANCE, "you wont catch shit");

SPRING_LENGTH = 20;
assert(SPRING_LENGTH < BLADE_CUTAWAY_LENGTH, "spring cant be shorter than cutaway");

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

// Sword
difference() {
  Blade();
  // Cutaway
  move([BLADE_CUTAWAY_WIDTH, BLADE_CUTAWAY_LENGTH, 0])
    cube(BLADE_LENGTH, anchor=BACK + RIGHT);
}

// Hilt
right(BLADE_WIDTH / 2)
  cube(
    [
      HILT_WIDTH,
      HILT_LENGTH,
      HILT_HEIGHT,
    ], anchor=[0, 1, 0]
  );

right(BLADE_WIDTH / 2)
  cube(
    [
      HILT_WIDTH,
      HILT_LENGTH,
      HILT_HEIGHT,
    ], anchor=[0, 1, 0]
  );

// Handguard

HANDLE_POS = BLADE_WIDTH / 2 + HANDLE_X_OFFSET;

xrot(90)
  move([HANDLE_POS, 0, HILT_LENGTH])
    cylinder(h=HANDLE_LENGTH, r=HANDLE_RADIUS, anchor=[0, 0, -1]);

right(HANDLE_POS)
  fwd(HILT_LENGTH + HANDLE_LENGTH)
    cube(
      [
        HANDGUARD_POMMEL_X + EPS,
        HANDGUARD_WIDTH,
        HANDGUARD_THICKNESS,
      ], anchor=[0, 1, 0]
    );

fwd(HANDLE_LENGTH + HANDGUARD_WIDTH + HILT_LENGTH)
  right(HANDLE_POS + HANDGUARD_POMMEL_X / 2)
    intersection() {
      difference() {
        resize(
          [
            HANDGUARD_RX * 2,
            HANDGUARD_RY * 2,
            HANDGUARD_THICKNESS,
          ]
        )
          cylinder(h=HANDGUARD_THICKNESS, r=HANDGUARD_RY, anchor=FRONT);

        back(HANDGUARD_WIDTH)
          resize(
            [
              (HANDGUARD_RX - HANDGUARD_WIDTH) * 2,
              (HANDGUARD_RY - HANDGUARD_WIDTH) * 2,
              2 * HANDGUARD_THICKNESS,
            ]
          )
            cylinder(h=HANDGUARD_THICKNESS, r=HANDGUARD_RY, anchor=FRONT);
      }
      cube([HANDGUARD_RX * 2, HANDGUARD_RY * 2, HANDGUARD_THICKNESS * 2], anchor=LEFT);
    }

right(HANDLE_POS + HANDGUARD_POMMEL_X / 2 + HANDGUARD_RX)
  fwd(HILT_LENGTH)
    cube(
      [
        HANDGUARD_WIDTH,
        HANDLE_LENGTH - HANDGUARD_RY + HANDGUARD_WIDTH + EPS,
        HANDGUARD_THICKNESS,
      ], anchor=RIGHT + BACK
    );

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

union() {
  difference() {
    back(TOLERANCE)
      Sheath(SHEATH_THICKNESS + TOLERANCE, SHEATH_LENGTH + SHEATH_THICKNESS);
    Sheath(TOLERANCE, SHEATH_LENGTH + TOLERANCE);
    left(TOLERANCE) {
      // End Window
      back(TOLERANCE + BOT_WINDOW_POSITION)
        cube([BLADE_WIDTH * 1.2, SHEATH_WINDOW, BLADE_THICKNESS], anchor=BACK + LEFT + BOTTOM);
      // Mid Window
      back(TOLERANCE + MID_WINDOW_POSITION)
        cube([BLADE_WIDTH * 1.2, SHEATH_WINDOW, BLADE_THICKNESS], anchor=LEFT + BOTTOM);
      // Top Window
      back(TOLERANCE + TOP_WINDOW_POSITION)
        cube([BLADE_WIDTH * 1.2, SHEATH_WINDOW, BLADE_THICKNESS], anchor=FRONT + LEFT + BOTTOM);
    }

    // Spring Hole
    back(BLADE_CUTAWAY_LENGTH)
      cube([BLADE_CUTAWAY_WIDTH, SPRING_LENGTH, BLADE_THICKNESS], anchor=BACK + LEFT + TOP);
  }
  // Spring
  move(
    [
      TOLERANCE,
      BLADE_CUTAWAY_LENGTH - TOLERANCE,
      -BLADE_THICKNESS / 2 - TOLERANCE,
    ]
  )
    cube([SPRING_WIDTH, SPRING_LENGTH + TOLERANCE, SHEATH_THICKNESS], anchor=BACK + LEFT + TOP);

  move(
    [
      TOLERANCE,
      BLADE_CUTAWAY_LENGTH - TOLERANCE,
      -BLADE_THICKNESS / 2 - TOLERANCE,
    ]
  ) {
    cube([SPRING_WIDTH, CATCH_LENGTH, CATCH_HEIGHT], anchor=BACK + LEFT + BOTTOM);
    prismoid(
      size1=[SPRING_WIDTH, CATCH_LENGTH * 2],
      size2=[SPRING_WIDTH, 0],
      h=CATCH_HEIGHT,
      anchor=BACK + LEFT + BOTTOM
    );
  }
}
