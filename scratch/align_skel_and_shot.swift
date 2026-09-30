import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// Ribcage in Older Boy Skeleton.png:
// x: 640..855 (w: 216), y: 625..865 (h: 241)
// Ribcage in Screenshot:
// x: 68..138 (w: 71), y: 106..178 (h: 73)

let scaleX = 71.0 / 216.0 // 0.3287
let scaleY = 73.0 / 241.0 // 0.3029
print(String(format: "Ribcage scale factor: sx=%.4f, sy=%.4f", scaleX, scaleY))

// If we scale Older Boy Skeleton by scale (0.33):
// Where would skull be?
// Skull in Older Boy Skeleton: x: 700..863, y: 372..536
// Relative to ribcage top-left (640, 625):
// skull dx: (700..863) - 640 = 60..223
// skull dy: (372..536) - 625 = -253..-89
// Scaled dx: (60..223) * 0.33 = 19.8..73.6
// Scaled dy: (-253..-89) * 0.33 = -83.5..-29.4
// In screenshot, ribcage top-left is (68, 106)
// Expected skull in screenshot if unshifted:
// x: 68 + (19.8..73.6) = 87.8..141.6
// y: 106 + (-83.5..-29.4) = 22.5..76.6

// ACTUAL skull in screenshot:
// x: 81..133
// y: 33..82

print("Expected skull without shift: x: 87.8..141.6, y: 22.5..76.6")
print("Actual skull in screenshot:   x: 81.0..133.0, y: 33.0..82.0")
print(String(format: "Skull shift in screenshot: dx = %.1f (LEFT), dy = %.1f (DOWN)",
    81.0 - 87.8, 33.0 - 22.5))

