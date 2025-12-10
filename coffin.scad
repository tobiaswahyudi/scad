include <BOSL2/std.scad>

$fs = 0.5;
$fa = 1;

EPS = 0.01;

TOLERANCE = 0.3;

COFFIN_BOTTOM_WIDTH = 40;
COFFIN_MIDDLE_WIDTH = 60;
COFFIN_TOP_WIDTH = 40;

COFFIN_MIDDLE_LENGTH = 110;
COFFIN_LENGTH = 160;

COFFIN_HEIGHT = 30;

WALL_THICKNESS = 3;

MAGNET_DIAMETER = 5;
MAGNET_HEIGHT = 2.5;

PILLAR_DIAMETER = 9;

FOOT_SIZE = 2;

TOP_PILLAR_OFFSET = [.8, 1];
BOTTOM_PILLAR_OFFSET = [.8, 1, 0];

module CoffinShape(
  bottomWidth = COFFIN_BOTTOM_WIDTH,
  middleWidth = COFFIN_MIDDLE_WIDTH,
  topWidth = COFFIN_TOP_WIDTH,
  middleLength = COFFIN_MIDDLE_LENGTH,
  length = COFFIN_LENGTH,
  height = COFFIN_HEIGHT
) {
  union() {
    xrot(-90)
      prismoid(
        size1=[bottomWidth, height],
        size2=[middleWidth, height],
        h=middleLength + EPS,
        anchor=BOTTOM + BACK
      );
    back(middleLength)
      xrot(-90)
        prismoid(
          size1=[middleWidth, height],
          size2=[topWidth, height],
          h=length - middleLength,
          anchor=BOTTOM + BACK
        );
  }
}

bx = COFFIN_BOTTOM_WIDTH / 2 - WALL_THICKNESS - BOTTOM_PILLAR_OFFSET[0];
by = WALL_THICKNESS + BOTTOM_PILLAR_OFFSET[1];

tx = COFFIN_TOP_WIDTH / 2 - WALL_THICKNESS - TOP_PILLAR_OFFSET[0];
ty = COFFIN_LENGTH - WALL_THICKNESS - TOP_PILLAR_OFFSET[1];

// Coffin
difference() {
  union() {
    difference() {
      union() {
        // Main Body
        CoffinShape();
        // Bottom Foot
        fwd(FOOT_SIZE)
          CoffinShape(
            COFFIN_BOTTOM_WIDTH + FOOT_SIZE * 2,
            COFFIN_MIDDLE_WIDTH + FOOT_SIZE * 2,
            COFFIN_TOP_WIDTH + FOOT_SIZE * 2,
            COFFIN_MIDDLE_LENGTH + FOOT_SIZE,
            COFFIN_LENGTH + FOOT_SIZE * 2,
            FOOT_SIZE
          );
        // Upper Lip
        fwd(FOOT_SIZE)
          up(COFFIN_HEIGHT - FOOT_SIZE)
            CoffinShape(
              COFFIN_BOTTOM_WIDTH + FOOT_SIZE * 2,
              COFFIN_MIDDLE_WIDTH + FOOT_SIZE * 2,
              COFFIN_TOP_WIDTH + FOOT_SIZE * 2,
              COFFIN_MIDDLE_LENGTH + FOOT_SIZE,
              COFFIN_LENGTH + FOOT_SIZE * 2,
              FOOT_SIZE
            );
      }

      // Minus Coffin Hole
      back(WALL_THICKNESS)
        up(WALL_THICKNESS)
          CoffinShape(
            COFFIN_BOTTOM_WIDTH - 2 * WALL_THICKNESS,
            COFFIN_MIDDLE_WIDTH - 2 * WALL_THICKNESS,
            COFFIN_TOP_WIDTH - 2 * WALL_THICKNESS,
            COFFIN_MIDDLE_LENGTH - WALL_THICKNESS,
            COFFIN_LENGTH - 2 * WALL_THICKNESS,
            COFFIN_HEIGHT
          );
    }
    // Intersect with Pillars
    intersection() {
      union() {
        move([bx, by, 0])
          cylinder(d=PILLAR_DIAMETER, h=COFFIN_HEIGHT, anchor=BOTTOM);
        move([-bx, by, 0])
          cylinder(d=PILLAR_DIAMETER, h=COFFIN_HEIGHT, anchor=BOTTOM);
        move([tx, ty, 0])
          cylinder(d=PILLAR_DIAMETER, h=COFFIN_HEIGHT, anchor=BOTTOM);
        move([-tx, ty, 0])
          cylinder(d=PILLAR_DIAMETER, h=COFFIN_HEIGHT, anchor=BOTTOM);
      }
      CoffinShape();
    }
  }
  // Minus Magnet Holes
  move([bx, by, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=2 * MAGNET_HEIGHT, anchor=[0, 0, 0]);
  move([-bx, by, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=2 * MAGNET_HEIGHT, anchor=[0, 0, 0]);
  move([tx, ty, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=2 * MAGNET_HEIGHT, anchor=[0, 0, 0]);
  move([-tx, ty, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=2 * MAGNET_HEIGHT, anchor=[0, 0, 0]);
}
