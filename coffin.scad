include <BOSL2/std.scad>

$fs = 0.5;
$fa = 1;

EPS = 0.01;

TOLERANCE = 0.3;

COFFIN_BOTTOM_WIDTH = 35;
COFFIN_MIDDLE_WIDTH = 55;
COFFIN_TOP_WIDTH = 35;

COFFIN_MIDDLE_LENGTH = 86;
COFFIN_LENGTH = 120;

COFFIN_HEIGHT = 35;

WALL_THICKNESS = 3;

MAGNET_DIAMETER = 5.8;
MAGNET_HEIGHT = 2.55;

MAGNET_WALL = 0.6;

LIP_HEIGHT = 3;
LIP_THICKNESS = 1.5;

PILLAR_DIAMETER = 9;

FOOT_SIZE = 2;

TOP_PILLAR_OFFSET = [.8, 1];
BOTTOM_PILLAR_OFFSET = [.8, 1, 0];

LID_TOP_EDGE_HEIGHT = 2;
LID_TOP_CHAMFER = 4;
LID_TOP_HEIGHT = 4;

LID_INSET_BORDER = 3;
LID_INSET_DEPTH = 1;

PENTAGRAM_DIAMETER = 22;
PENTAGRAM_HEIGHT = 1;
PENTAGRAM_THICKNESS = 1;
PENTAGRAM_MIDDLE_OFFSET = 2;

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
  down(MAGNET_WALL) {
  move([bx, by, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  move([-bx, by, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  move([tx, ty, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  move([-tx, ty, COFFIN_HEIGHT])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  }
}

module coffinLidLip() {
  down(LIP_HEIGHT - EPS)
    back(WALL_THICKNESS + TOLERANCE)
      CoffinShape(
        COFFIN_BOTTOM_WIDTH - 2 * (WALL_THICKNESS + TOLERANCE),
        COFFIN_MIDDLE_WIDTH - 2 * (WALL_THICKNESS + TOLERANCE),
        COFFIN_TOP_WIDTH - 2 * (WALL_THICKNESS + TOLERANCE),
        COFFIN_MIDDLE_LENGTH - (WALL_THICKNESS + TOLERANCE),
        COFFIN_LENGTH - 2 * (WALL_THICKNESS + TOLERANCE),
        LIP_HEIGHT
      );
}

// Coffin Lid
difference() {
union() {
up(COFFIN_HEIGHT + 20) {
  fwd(FOOT_SIZE)
    CoffinShape(
      COFFIN_BOTTOM_WIDTH + FOOT_SIZE * 2,
      COFFIN_MIDDLE_WIDTH + FOOT_SIZE * 2,
      COFFIN_TOP_WIDTH + FOOT_SIZE * 2,
      COFFIN_MIDDLE_LENGTH + FOOT_SIZE,
      COFFIN_LENGTH + FOOT_SIZE * 2,
      FOOT_SIZE
    );
  // Lip
  difference() {
    union() {
      difference() {
        coffinLidLip();
        down(LIP_HEIGHT - EPS + 1)
          back(WALL_THICKNESS + TOLERANCE + LIP_THICKNESS)
            CoffinShape(
              COFFIN_BOTTOM_WIDTH - 2 * (WALL_THICKNESS + TOLERANCE + LIP_THICKNESS),
              COFFIN_MIDDLE_WIDTH - 2 * (WALL_THICKNESS + TOLERANCE + LIP_THICKNESS),
              COFFIN_TOP_WIDTH - 2 * (WALL_THICKNESS + TOLERANCE + LIP_THICKNESS),
              COFFIN_MIDDLE_LENGTH - (WALL_THICKNESS + TOLERANCE + LIP_THICKNESS),
              COFFIN_LENGTH - 2 * (WALL_THICKNESS + TOLERANCE + LIP_THICKNESS),
              LIP_HEIGHT + 1
            );
      }
      intersection() {
        coffinLidLip();
        up(EPS) union() {
            move([bx, by, 0])
              cylinder(d=PILLAR_DIAMETER + 2 * (TOLERANCE + LIP_THICKNESS), h=COFFIN_HEIGHT, anchor=TOP);
            move([-bx, by, 0])
              cylinder(d=PILLAR_DIAMETER + 2 * (TOLERANCE + LIP_THICKNESS), h=COFFIN_HEIGHT, anchor=TOP);
            move([tx, ty, 0])
              cylinder(d=PILLAR_DIAMETER + 2 * (TOLERANCE + LIP_THICKNESS), h=COFFIN_HEIGHT, anchor=TOP);
            move([-tx, ty, 0])
              cylinder(d=PILLAR_DIAMETER + 2 * (TOLERANCE + LIP_THICKNESS), h=COFFIN_HEIGHT, anchor=TOP);
          }
      }
    }

    up(EPS) {
      move([bx, by, 0])
        cylinder(d=PILLAR_DIAMETER + (2 * TOLERANCE), h=COFFIN_HEIGHT, anchor=TOP);
      move([-bx, by, 0])
        cylinder(d=PILLAR_DIAMETER + (2 * TOLERANCE), h=COFFIN_HEIGHT, anchor=TOP);
      move([tx, ty, 0])
        cylinder(d=PILLAR_DIAMETER + (2 * TOLERANCE), h=COFFIN_HEIGHT, anchor=TOP);
      move([-tx, ty, 0])
        cylinder(d=PILLAR_DIAMETER + (2 * TOLERANCE), h=COFFIN_HEIGHT, anchor=TOP);
    }
  }
  // Lid Top
  difference() {
    up(FOOT_SIZE)
      union() {
        xrot(-90)
          prismoid(
            size1=[COFFIN_BOTTOM_WIDTH, LID_TOP_HEIGHT],
            size2=[COFFIN_MIDDLE_WIDTH, LID_TOP_HEIGHT],
            h=COFFIN_MIDDLE_LENGTH + EPS,
            anchor=BOTTOM + BACK
          );
        back(COFFIN_MIDDLE_LENGTH)
          xrot(-90)
            prismoid(
              size1=[COFFIN_MIDDLE_WIDTH, LID_TOP_HEIGHT],
              size2=[COFFIN_TOP_WIDTH, LID_TOP_HEIGHT],
              h=COFFIN_LENGTH - COFFIN_MIDDLE_LENGTH,
              anchor=BOTTOM + BACK
            );

        up(LID_TOP_HEIGHT - EPS)
          polyhedron(
            points=[
              [COFFIN_BOTTOM_WIDTH / 2, 0, 0],
              [COFFIN_MIDDLE_WIDTH / 2, COFFIN_MIDDLE_LENGTH, 0],
              [COFFIN_TOP_WIDTH / 2, COFFIN_LENGTH, 0],

              [-COFFIN_TOP_WIDTH / 2, COFFIN_LENGTH, 0],
              [-COFFIN_MIDDLE_WIDTH / 2, COFFIN_MIDDLE_LENGTH, 0],
              [-COFFIN_BOTTOM_WIDTH / 2, 0, 0],

              [COFFIN_BOTTOM_WIDTH / 2 - LID_TOP_CHAMFER, LID_TOP_CHAMFER, LID_TOP_CHAMFER],
              [COFFIN_MIDDLE_WIDTH / 2 - LID_TOP_CHAMFER, COFFIN_MIDDLE_LENGTH, LID_TOP_CHAMFER],
              [COFFIN_TOP_WIDTH / 2 - LID_TOP_CHAMFER, COFFIN_LENGTH - LID_TOP_CHAMFER, LID_TOP_CHAMFER],

              [-COFFIN_TOP_WIDTH / 2 + LID_TOP_CHAMFER, COFFIN_LENGTH - LID_TOP_CHAMFER, LID_TOP_CHAMFER],
              [-COFFIN_MIDDLE_WIDTH / 2 + LID_TOP_CHAMFER, COFFIN_MIDDLE_LENGTH, LID_TOP_CHAMFER],
              [-COFFIN_BOTTOM_WIDTH / 2 + LID_TOP_CHAMFER, LID_TOP_CHAMFER, LID_TOP_CHAMFER],
            ],
            faces=[
              [0, 1, 2, 3, 4, 5],
              [11, 10, 9, 8, 7, 6],
              [11, 6, 0, 5],
              [8, 9, 3, 2],
              [6, 7, 1, 0],
              [7, 8, 2, 1],
              [10, 11, 5, 4],
              [9, 10, 4, 3],
            ]
          );
      }
    up(FOOT_SIZE + LID_TOP_HEIGHT + LID_TOP_CHAMFER - LID_INSET_DEPTH)
      back(LID_TOP_CHAMFER + LID_INSET_BORDER)
        CoffinShape(
          COFFIN_BOTTOM_WIDTH - (LID_TOP_CHAMFER + LID_INSET_BORDER) * 2,
          COFFIN_MIDDLE_WIDTH - (LID_TOP_CHAMFER + LID_INSET_BORDER) * 2,
          COFFIN_TOP_WIDTH - (LID_TOP_CHAMFER + LID_INSET_BORDER) * 2,
          COFFIN_MIDDLE_LENGTH - (LID_TOP_CHAMFER + LID_INSET_BORDER),
          COFFIN_LENGTH - (LID_TOP_CHAMFER + LID_INSET_BORDER) * 2,
          COFFIN_HEIGHT
        );
  }
  up(FOOT_SIZE + LID_TOP_HEIGHT + LID_TOP_CHAMFER - LID_INSET_DEPTH - EPS)
    back(COFFIN_MIDDLE_LENGTH + PENTAGRAM_MIDDLE_OFFSET) {
      // Pentagram
      difference() {
        cylinder(d=PENTAGRAM_DIAMETER, h=PENTAGRAM_HEIGHT);
        down(1)
          cylinder(d=PENTAGRAM_DIAMETER - PENTAGRAM_THICKNESS * 2, h=PENTAGRAM_HEIGHT + 2);
      }

      intersection() {
        cylinder(d=PENTAGRAM_DIAMETER, h=PENTAGRAM_HEIGHT);
        union() {
          for (i = [0:1:4]) {
            rotate(72 * i)
              back(PENTAGRAM_DIAMETER / 2)
                rot(18)
                  cube([PENTAGRAM_THICKNESS, PENTAGRAM_DIAMETER, PENTAGRAM_HEIGHT], anchor=BOTTOM + BACK);
          }
        }
      }

        // up(30)
        //   text3d("6", size=10, h=2, font="Herculanum");
    }
}
}
// Minus magnet holes

up(COFFIN_HEIGHT + 20 + MAGNET_HEIGHT + MAGNET_WALL) {
  move([bx, by, 0])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  move([-bx, by, 0])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  move([tx, ty, 0])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  move([-tx, ty, 0])
    cylinder(d=MAGNET_DIAMETER, h=MAGNET_HEIGHT, anchor=TOP);
  }
}