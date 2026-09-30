import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

func getCleanPixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = c.redComponent
    let g = c.greenComponent
    let b = c.blueComponent
    if r > 0.78 && g > 0.78 && b > 0.78 { return c }
    if b > 0.38 && g > 0.32 && g > r + 0.03 { return c }
    if x >= 810 && x <= 865 && y >= 440 && y <= 515 && r < 0.25 && g < 0.25 && b < 0.35 { return c }
    return nil
}

// 1. Where does the skull start and end?
// Top of skull: y = 372
// Back of skull: x = 700
// Front of skull: x = 863
// Bottom of jaw: y = 536
print("Skull: x: 700..863, y: 372..536")

// 2. Where does the cervical spine start and end?
// Cervical spine starts right under skull: y = 535
// Top of cervical spine is x: 720..775, y: 535..630
// Clavicles start at y: 630. Clavicle left tip: x=640, y=650. Clavicle right tip: x=867, y=650.
// Clavicle center arch: y=630.
print("Clavicles arch: top y=630, tips at y=650, x: 640..867")

// 3. Ribcage bottom:
// Bottom-most rib: x=690, y=865. Sternum xiphoid: x=755, y=780.
print("Ribcage bottom: y=865")

// 4. Lumbar spine:
// Runs from y=780 down to y=945 (into pelvis)
print("Lumbar spine: y=780..945")

// 5. Pelvis:
// Iliac crest top: y=935
// Bottom of ischium: y=1080
// Width: x: 655..875
print("Pelvis: x: 655..875, y: 935..1080")

// 6. Left arm (humerus):
// Shoulder joint: x=640..670, y=645
// Elbow joint: x=596..645, y=805
print("Humerus Left: x: 596..675, y: 645..805")

