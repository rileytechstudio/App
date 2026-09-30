import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

// Skeleton source dimensions in Older Boy Skeleton.png:
// Whole skeleton: x: 596..1010 (w: 415), y: 371..1633 (h: 1263)
// Skull in source: x: 700..863 (w: 164), y: 371..536 (h: 165)
// Spine in source: x: 720..785 (w: 66), y: 535..945 (h: 411)
// Ribcage in source: x: 635..870 (w: 236), y: 625..865 (h: 241)
// Pelvis in source: x: 655..875 (w: 221), y: 935..1080 (h: 146)

// Body placement parameters (from clavicles y=625 down to feet y=1633):
// In screenshot:
// Clavicles start at normY = 148.7 px (in 681 height)
// Feet end at normY = 676 px
// Total body height from clavicles to feet = 676 - 148.7 = 527.3 px
// In source: clavicles (y=625) to feet (y=1633) = 1008 px
// Body scale Y = 527.3 / 1008 = 0.5231
// Body scale X: In screenshot, skeleton width at ribs = 197.35 px / 415 = 0.4755
let bodyScaleX = 197.35 / 415.0
let bodyScaleY = 527.3 / 1008.0

// Body X offset:
let bodyMinX = 4.85
// Clavicles at y=625 in source map to y = 148.7 in char:
// y_char = 148.7 + (y_src - 625) * bodyScaleY
func bodyY(_ ySrc: Double) -> Double {
    return 148.7 + (ySrc - 625.0) * bodyScaleY
}
func bodyX(_ xSrc: Double) -> Double {
    return bodyMinX + (xSrc - 596.0) * bodyScaleX
}

print("Body mapped landmarks:")
print("  Clavicles top: \(bodyY(625.0))")
print("  Ribs bottom: \(bodyY(865.0))")
print("  Pelvis top: \(bodyY(935.0))")
print("  Pelvis bottom: \(bodyY(1080.0))")
print("  Knees: \(bodyY(1315.0))")
print("  Feet bottom: \(bodyY(1633.0))")

// Skull in screenshot:
// x: 61.5..145.6 (w: 84.1), y: 52.8..124.7 (h: 71.9)
// If we draw skull at:
let skullDestX = 61.5
let skullDestY = 52.8
let skullDestW = 84.1
let skullDestH = 72.0 // matches 164x165 aspect closely

// Now cervical spine:
// Connects from skull base (y ≈ 100 px, x ≈ 95 px) to clavicles / thoracic spine (y ≈ 148.7 px)
