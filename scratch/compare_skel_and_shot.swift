import AppKit

// In Older Boy Skeleton.png:
// Whole skeleton: x: 596..967 (w:372), y: 372..1633 (h:1262)
// Skull top: 372, bottom: 536. (y-distance from top: 0 to 164)
// Clavicles/ribcage top: y=625. (y-distance from top: 625 - 372 = 253)
// Distance skull-bottom to ribcage-top: 625 - 536 = 89 pixels in 1262h (7.05%)

// In Screenshot 2026-09-29 at 9.22.14 AM.png:
// Whole skeleton: y: 33..448 (h:416)
// Skull top: 33, bottom: 82. (y-distance from top: 0 to 49)
// Clavicles/ribcage top: y=106. (y-distance from top: 106 - 33 = 73)
// Distance skull-bottom to ribcage-top: 106 - 82 = 24 pixels in 416h (5.77%)

// Notice in Older Boy Skeleton.png: 253 / 1262 = 20.04% of skeleton height
// In Screenshot: 73 / 416 = 17.55% of skeleton height!
// THAT IS A DIFFERENCE OF 2.5% of skeleton height (about 31 pixels in high-res)!
print(String(format: "Original distance skull-to-ribs: %.2f%%", 89.0 / 1262.0 * 100.0))
print(String(format: "Screenshot distance skull-to-ribs: %.2f%%", 24.0 / 416.0 * 100.0))

// Let's also check X positions:
// In Older Boy Skeleton.png:
// Skull: x: 700..863 (center = 781.5). Relative to skel (596..967, w=372): (781.5 - 596) / 372 = 49.86%
// Ribcage: x: 640..855 (center = 747.5). Relative to skel: (747.5 - 596) / 372 = 40.72%

// In Screenshot:
// Whole skel: x: 46..168 (w=123)
// Skull: x: 81..133 (center = 107.0). Relative to skel: (107.0 - 46.0) / 123.0 = 49.59%
// Ribcage: x: 68..138 (center = 103.0). Relative to skel: (103.0 - 46.0) / 123.0 = 46.34%

print("In Older Boy Skeleton.png:")
print("Skull center X in skel: 49.86%, Ribcage center X in skel: 40.72%")
print("In Screenshot:")
print("Skull center X in skel: 49.59%, Ribcage center X in skel: 46.34%")

