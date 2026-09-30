import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// In Older Boy Skeleton.png:
// Skull: x: 700..863, y: 372..536
// Cervical spine top: y: 550, x: 730..770
// Distance between skull bottom (536) and cervical spine top (550) is ~14 pixels.
// And look at the angle: cervical spine top is angled at ~15 degrees!
// What if we shift the skull down by 20 pixels and right by 10 pixels?

print("Testing skull shift...")
